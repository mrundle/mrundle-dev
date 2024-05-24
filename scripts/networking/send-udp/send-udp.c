/*
 * Ever want to just send the dang udp packets?
 * This lets you do that from one host to another, while also controlling both
 * the source and destination ports to fix a 5-tuple.
 *
 * Note: currently hardcoded to send just 3 packets; be careful blasting more
 * there is no sleep/wait to smooth out transmission, so you'll be limited
 * by your local hardware and whatever lays beyond
 */

/* gcc send-udp.c -o send-udp */
/*
 * Send a UDP packet to server.c.
 */

//#define PACKETS (100 * 1000)
#define PACKETS 3 // TODO config
#define PACKET_LEN 1450 // max mtu 1500; TODO config

#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <string.h>

int
main(int argc, char *argv[])
{
    struct sockaddr_in client;
    struct sockaddr_in server;
    
    if(argc != 4){
        fprintf(stderr, "Usage: dst_host sport dport\n");
        /* TODO: make configurable:
         *     - n_packets
         *     - packet_size
         *
         * TODO: packet rate? or just reimplementing iperf at that point
         */
        return 1;
    }
    const char *const server_str = argv[1];
    const char *const sport_str = argv[2];
    const char *const dport_str = argv[3];

    const int sock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (sock < 0) {
        perror("socket");
        return 1;
    }

    unsigned sport = strtoul(sport_str, NULL, 10);
    if (sport == 0 || sport > UINT16_MAX) {
        fprintf(stderr, "bad sport '%s'\n", sport_str);
        return 1;
    }
    printf("sport %u\n", sport);

    unsigned dport = strtoul(dport_str, NULL, 10);
    if (dport == 0 || dport > UINT16_MAX) {
        fprintf(stderr, "bad dport '%s'\n", dport_str);
        return 1;
    }
    printf("dport %u\n", dport);

    /* src */
    client.sin_addr.s_addr = INADDR_ANY;
    client.sin_port = htons(sport);
    client.sin_family = AF_INET;

    /* bind to src port */
    if (bind(sock, (struct sockaddr *)&client, sizeof(client)) != 0) {
        fprintf(stderr, "failed to bind src port %u\n", sport);
	return 1;
    }

    /* dst */
    struct in_addr dst_ip;
    if (inet_aton(server_str, &server.sin_addr) == 0) {
        fprintf(stderr, "bad dest ip '%s'\n", server_str);
        return 1;
    }
    server.sin_family = AF_INET;
    server.sin_port = htons(dport);

    unsigned char data[PACKET_LEN] = "test";
    memset(data, 0xff, PACKET_LEN);

    for (unsigned i = 0; i < PACKETS; i++) {
        int sent = sendto(sock, data, PACKET_LEN, 0, (struct sockaddr *)&server, sizeof(server));
        if (sent != (int)PACKET_LEN) {
            fprintf(stderr, "failed to send udp packet to %s:%s\n", server_str, dport_str);
	    return 1;
        } else {
            //printf("sent %u byte udp packet to %s:%s\n", PACKET_LEN, server_str, dport_str, data);
        }
    }
    printf("sent %u packets\n", PACKETS);
}
