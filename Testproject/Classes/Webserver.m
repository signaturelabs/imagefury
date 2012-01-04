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

@implementation Webserver

+ (Webserver*)shared {
    
    static Webserver *instance = nil;
    
    if(!instance)
        instance = [Webserver new];
    
    return instance;
}

/// The request header is placed in 'header'.  Take the request and give a response to the socket
/// specified by 'sock'.  Use blocking send() to send the client the response.
/// After this method is called, the sock will be closed.
- (void)handleRequest:(NSString*)header client:(int)sock {
    
    const char *ptr =
    [[[@"<html><body><pre>" stringByAppendingString:header] stringByAppendingString:@"</pre></body></html>"] UTF8String];
    
    send(sock, ptr, strlen(ptr), 0);
}

- (void)server {
    
    @autoreleasepool {
        
        NSMutableArray *clientData = [NSMutableArray array];
        
        struct addrinfo hints, *res;
        
        memset(&hints, 0, sizeof hints);
        
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_flags = AI_PASSIVE;
        
        getaddrinfo(NULL, "4321", &hints, &res);
        
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
                            
                            NSMutableString *str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                            
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
                
                clients = reallocf(clients, clientCount += 1);
                
                clients[clientCount - 1] = accept(msock, NULL, NULL);
                
                assert(clients[clientCount - 1] != -1);
                
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
