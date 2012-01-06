//
//  Webserver.m
//  imagefury
//
//  Created by Dustin Dettmer on 1/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Webserver.h"

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <poll.h>
#include <fcntl.h>

@implementation Webserver

+ (Webserver*)shared {
    
    static Webserver *instance = nil;
    
    if(!instance)
        instance = [Webserver new];
    
    return instance;
}

- (NSString*)queryParm:(NSString*)named query:(NSString*)path {
    
    named = [NSRegularExpression escapedPatternForString:named];
    
    NSString *pattern = [@"[?|&]<named>=([^&])" stringByReplacingOccurrencesOfString:@"<named>"
                                                                          withString:named];
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:nil];
    
    NSTextCheckingResult *res = [reg firstMatchInString:path
                                                options:0
                                                  range:(NSRange){0, path.length}];
    
    if(!res)
        return nil;
    
    NSRange range = [res rangeAtIndex:1];
    
    if(range.location == NSNotFound)
        return nil;
    
    return [path substringWithRange:range];
}

/// The request header is placed in 'header'.  Take the request and give a response to the socket
/// specified by 'sock'.  Use blocking send() to send the client the response.
/// After this method is called, the sock will be closed.
- (void)handleRequest:(NSString*)header client:(int)sock {
    
    NSString *pattern = @"^GET ([^ ]+) ";
    
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                         options:0
                                                                           error:nil];
    
    NSTextCheckingResult *res = [reg firstMatchInString:header
                                                options:0
                                                  range:(NSRange){0, header.length}];
    
    NSString *query = [header substringWithRange:[res rangeAtIndex:1]];
    
    NSString *path = [[query componentsSeparatedByString:@"?"] objectAtIndex:0];
    
    if(path.length) {
        
        path = [path substringFromIndex:1];
        
        NSString *base = path.stringByDeletingPathExtension;
        NSString *type = path.pathExtension;
        
        NSString *filename = [NSBundle.mainBundle pathForResource:base ofType:type];
        
        if(!filename) {
            
            char *header404 = ""
            "HTTP/1.1 404 Not Found\r\n"
            "\r\n";
            
            send(sock, header404, strlen(header404), 0);
            
            return;
        }
        
        if(![type isEqualToString:@"txt"]) {
            
            NSMutableString *header = [NSMutableString stringWithString:@""
                                       "HTTP/1.1 200 OK\r\n"
                                       "Content-Type: image/<type>\r\n"
                                       "\r\n"];
            
            [header replaceOccurrencesOfString:@"<type>"
                                    withString:type
                                       options:0
                                         range:(NSRange){0, header.length}];
            
            NSData *data = [header dataUsingEncoding:NSUTF8StringEncoding];
            
            send(sock, data.bytes, data.length, 0);
        }
        
        int fd = open(filename.fileSystemRepresentation, O_RDONLY);
        
        unsigned long long fileSize = [[NSFileManager.defaultManager attributesOfItemAtPath:filename
                                                                                      error:nil] fileSize];
        
        int bytesSent = 0;
        
        while(1) {
            
            char buf[rand() % 1024];
            
            int read_ret = read(fd, buf, sizeof buf);
            
            if(read_ret == 0 || read_ret == -1)
                break;
            
            send(sock, buf, read_ret, 0);
            
            bytesSent += read_ret;
            
            if([self queryParm:@"fail" query:query])
                if(bytesSent * 2 > fileSize)
                    break;
            
            if([self queryParm:@"slow" query:query])
                if(bytesSent * 2 > fileSize)
                    [NSThread sleepForTimeInterval:(rand() % 10) / 10.0f];
        }
        
        close(fd);
    }
}

- (void)server {
    
    @autoreleasepool {
        
        NSMutableArray *clientData = [NSMutableArray array];
        
        struct addrinfo hints, *res;
        
        memset(&hints, 0, sizeof hints);
        
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_PASSIVE;
        
        getaddrinfo(NULL, WEBSERVER_PORT, &hints, &res);
        
        int msock = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
        
        assert(msock != -1);
        
        int rbind = bind(msock, res->ai_addr, res->ai_addrlen);
        
        assert(rbind != -1);
        
        freeaddrinfo(res);
        res = NULL;
        
        int yes = 1;
        
        int rsetopt = setsockopt(msock, SOL_SOCKET, SO_REUSEADDR, &yes, sizeof(int));
        
        assert(rsetopt != -1);
        
        int rlisten = listen(msock, 10);
        
        assert(rlisten != -1);
        
        int *clients = NULL;
        int clientCount = 0;
        
        while(1) {
            
            struct pollfd pollfds[clientCount + 1];
            
            pollfds[0].fd = msock;
            pollfds[0].events = POLLIN;
            pollfds[0].revents = 0;
            
            for(int i = 0; i < clientCount; i++) {
                
                pollfds[i + 1].fd = clients[i];
                pollfds[i + 1].events = POLLIN;
                pollfds[i + 1].revents = 0;
            }
            
            int rpoll = poll(pollfds, clientCount + 1, -1);
            
            assert(rpoll != -1);
            
            // Loop through each client and give the right reaction to wherever we are
            // with them.
            for(int i = 0; i < clientCount; i++) {
                
                if(pollfds[i + 1].revents & POLLIN) {
                    
                    NSMutableData *data = [clientData objectAtIndex:i];
                    
                    char buf[1024];
                    
                    int rrecv = recv(clients[i], buf, sizeof(buf), 0);
                    
                    if(rrecv == -1 && errno == ENOTCONN)
                        NSLog(@"Not connected recv.");
                    
                    assert(-1 != rrecv);
                    
                    // Connection dropped
                    if(rrecv == 0) {
                        
                        goto CloseConnection;
                    }
                    else {
                        
                        [data appendBytes:buf length:rrecv];
                        
                        if(strnstr(data.bytes, "\r\n\r\n", data.length)) {
                            
                            NSMutableString *str = [[NSMutableString alloc] initWithData:data
                                                                                encoding:NSUTF8StringEncoding];
                            
                            [self handleRequest:str client:clients[i]];
                            
                            [str release];
                            
                            goto CloseConnection;
                        }
                    }
                    
                    if(0) {
                        
                    CloseConnection:
                        
                        close(clients[i]);
                        
                        clientCount--;
                        
                        long dist = (clientCount - i) * sizeof clients[0];
                        
                        if(dist > 0)
                            memmove(clients + i, clients + i + 1, dist);
                        
                        clients = reallocf(clients, clientCount);
                        
                        [clientData removeObjectAtIndex:i];
                    }
                }
            }
            
            // A new client has connected
            if(pollfds[0].revents & POLLIN) {
                
                int fd = accept(msock, NULL, NULL);
                
                assert(fd != -1);
                
                int num = 1;
                
                setsockopt(fd, SOL_SOCKET, SO_NOSIGPIPE, &num, sizeof num);
                
                clients = reallocf(clients, clientCount += 1);
                
                clients[clientCount - 1] = fd;
                
                [clientData addObject:[NSMutableData data]];
            }
        }
        
        free(clients);
        close(msock);
    }
}

- (id)init {
    
    if((self = [super init])) {
        
        [self performSelectorInBackground:@selector(server) withObject:nil];
    }
    
    return self;
}

@end
