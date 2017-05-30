#include "includes/headers.p4"
#include "includes/parser.p4"

counter my_counter {
    type: packets;
    direct: forward;    
}

action _drop() {
    drop();
}

action set_dst(meta_ipv4, port) {
    modify_field(routing_metadata.meta_ipv4, meta_ipv4);
    modify_field(standard_metadata.egress_spec, port);
}

action set_dmac(dmac) {
    modify_field(ethernet.dstAddr, dmac);
}

action set_smac(smac) {
    modify_field(ethernet.srcAddr, smac);
}

table forward {
    reads {
        routing_metadata.meta_ipv4 : exact;
    }
    actions {
        set_dmac;
        _drop;
    }
}

table ipv4_dst {
    reads {
        ipv4.dstAddr : exact;
    }
    actions {
        set_dst;
        _drop;
    }
}

table dispatch {
    reads {
        standard_metadata.egress_port: exact;
    }
    actions {
        set_smac;
        _drop;
    }
}

control ingress {
    apply(ipv4_dst);
    apply(forward);
}

control egress {
    apply(dispatch);
}
