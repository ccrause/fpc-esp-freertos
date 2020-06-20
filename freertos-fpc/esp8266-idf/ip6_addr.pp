unit ip6_addr;

interface

const
  IP6_MULTICAST_SCOPE_RESERVED = $0;
  IP6_MULTICAST_SCOPE_RESERVED0 = $0;
  IP6_MULTICAST_SCOPE_INTERFACE_LOCAL = $1;
  IP6_MULTICAST_SCOPE_LINK_LOCAL = $2;
  IP6_MULTICAST_SCOPE_RESERVED3 = $3;
  IP6_MULTICAST_SCOPE_ADMIN_LOCAL = $4;
  IP6_MULTICAST_SCOPE_SITE_LOCAL = $5;
  IP6_MULTICAST_SCOPE_ORGANIZATION_LOCAL = $8;
  IP6_MULTICAST_SCOPE_GLOBAL = $e;
  IP6_MULTICAST_SCOPE_RESERVEDF = $f;
  IP6_ADDR_INVALID = $00;
  IP6_ADDR_TENTATIVE = $08;
  IP6_ADDR_TENTATIVE_1 = $09;
  IP6_ADDR_TENTATIVE_2 = $0a;
  IP6_ADDR_TENTATIVE_3 = $0b;
  IP6_ADDR_TENTATIVE_4 = $0c;
  IP6_ADDR_TENTATIVE_5 = $0d;
  IP6_ADDR_TENTATIVE_6 = $0e;
  IP6_ADDR_TENTATIVE_7 = $0f;
  IP6_ADDR_VALID = $10;
  IP6_ADDR_PREFERRED = $30;
  IP6_ADDR_DEPRECATED = $10;
  IP6_ADDR_TENTATIVE_COUNT_MASK = $07;
  IP6ADDR_STRLEN_MAX = 46;

type
  Pip6_addr = ^Tip6_addr;
  Tip6_addr = record
    addr: array[0..3] of uint32;
  end;

{
(* error 
  (ip6addr)->addr[index] = PP_HTONL(LWIP_MAKEU32(a,b,c,d))
in define line 67 *)

(* error 
#define IP6_ADDR(ip6addr, idx0, idx1, idx2, idx3) do { \
in declaration at line 72 *)
(* error 
  (ip6addr)->addr[0] = idx0; \
(* error 
  (ip6addr)->addr[1] = idx1; \
in declaration at line 73 *)
(* error 
  (ip6addr)->addr[1] = idx1; \
(* error 
  (ip6addr)->addr[2] = idx2; \
in declaration at line 74 *)
(* error 
  (ip6addr)->addr[2] = idx2; \
(* error 
  (ip6addr)->addr[3] = idx3; } while(0
in declaration at line 75 *)
(* error 
  (ip6addr)->addr[3] = idx3; } {while(0


in define line 78 *)

{ was #define dname(params) para_def_expr }
{ argument types are unknown }

function IP6_ADDR_BLOCK2(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK3(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK4(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK5(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK6(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK7(ip6addr: longint): Tu16_t;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK8(ip6addr: longint): Tu16_t;


(* error 
#define ip6_addr_copy(dest, src) do{(dest).addr[0] = (src).addr[0]; \
in declaration at line 95 *)
(* error 
#define ip6_addr_copy(dest, src) do{(dest).addr[0] = (src).addr[0]; \
(* error 
                                    (dest).addr[1] = (src).addr[1]; \
in declaration at line 96 *)
(* error 
                                    (dest).addr[1] = (src).addr[1]; \
(* error 
                                    (dest).addr[2] = (src).addr[2]; \
in declaration at line 97 *)
(* error 
                                    (dest).addr[2] = (src).addr[2]; \
(* error 
                                    (dest).addr[3] = (src).addr[3];}while(0
in declaration at line 98 *)
(* error 
                                    (dest).addr[3] = (src).addr[3];}while(0


in declaration at line 100 *)
(* error 
#define ip6_addr_set(dest, src) do{(dest)->addr[0] = (src) == NULL ? 0 : (src)->addr[0]; \
(* error 
                                   (dest)->addr[1] = (src) == NULL ? 0 : (src)->addr[1]; \
in declaration at line 101 *)
(* error 
                                   (dest)->addr[1] = (src) == NULL ? 0 : (src)->addr[1]; \
(* error 
                                   (dest)->addr[2] = (src) == NULL ? 0 : (src)->addr[2]; \
in declaration at line 102 *)
(* error 
                                   (dest)->addr[2] = (src) == NULL ? 0 : (src)->addr[2]; \
(* error 
                                   (dest)->addr[3] = (src) == NULL ? 0 : (src)->addr[3];}while(0
in declaration at line 103 *)
(* error 
                                   (dest)->addr[3] = (src) == NULL ? 0 : (src)->addr[3];}{while(0


in declaration at line 106 *)
(* error 
#define ip6_addr_set_zero(ip6addr)    do{(ip6addr)->addr[0] = 0; \
(* error 
                                         (ip6addr)->addr[1] = 0; \
in declaration at line 107 *)
(* error 
                                         (ip6addr)->addr[1] = 0; \
(* error 
                                         (ip6addr)->addr[2] = 0; \
in declaration at line 108 *)
(* error 
                                         (ip6addr)->addr[2] = 0; \
(* error 
                                         (ip6addr)->addr[3] = 0;}while(0
in declaration at line 109 *)
(* error 
                                         (ip6addr)->addr[3] = 0;}{while(0


in define line 112 *)

(* error 
#define ip6_addr_set_loopback(ip6addr) do{(ip6addr)->addr[0] = 0; \
in declaration at line 114 *)
(* error 
#define ip6_addr_set_loopback(ip6addr) do{(ip6addr)->addr[0] = 0; \
(* error 
                                          (ip6addr)->addr[1] = 0; \
in declaration at line 115 *)
(* error 
                                          (ip6addr)->addr[1] = 0; \
(* error 
                                          (ip6addr)->addr[2] = 0; \
in declaration at line 116 *)
(* error 
                                          (ip6addr)->addr[2] = 0; \
(* error 
                                          (ip6addr)->addr[3] = PP_HTONL(0x00000001UL);}while(0
in declaration at line 117 *)
(* error 
                                          (ip6addr)->addr[3] = PP_HTONL(0x00000001UL);}while(0


in declaration at line 120 *)
(* error 
#define ip6_addr_set_hton(dest, src) do{(dest)->addr[0] = (src) == NULL ? 0 : lwip_htonl((src)->addr[0]); \
(* error 
                                        (dest)->addr[1] = (src) == NULL ? 0 : lwip_htonl((src)->addr[1]); \
in declaration at line 121 *)
(* error 
                                        (dest)->addr[1] = (src) == NULL ? 0 : lwip_htonl((src)->addr[1]); \
(* error 
                                        (dest)->addr[2] = (src) == NULL ? 0 : lwip_htonl((src)->addr[2]); \
in declaration at line 122 *)
(* error 
                                        (dest)->addr[2] = (src) == NULL ? 0 : lwip_htonl((src)->addr[2]); \
(* error 
                                        (dest)->addr[3] = (src) == NULL ? 0 : lwip_htonl((src)->addr[3]);}while(0
in declaration at line 123 *)
(* error 
                                        (dest)->addr[3] = (src) == NULL ? 0 : lwip_htonl((src)->addr[3]);}{while(0


in define line 134 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_cmp(addr1, addr2: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_get_subnet_id(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isany_val(ip6addr: longint): longint;

(* error 
#define ip6_addr_isany(ip6addr) (((ip6addr) == NULL) || ip6_addr_isany_val(*(ip6addr)))
in define line 147 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isloopback(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isglobal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_islinklocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_issitelocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isuniquelocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isipv4mappedipv6(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_transient_flag(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_prefix_flag(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_rendezvous_flag(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_scope(ip6addr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }

function ip6_addr_ismulticast_iflocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_linklocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_adminlocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_sitelocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_orglocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_global(ip6addr: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isallnodes_iflocal(ip6addr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isallnodes_linklocal(ip6addr: longint): longint;

(* error
#define ip6_addr_set_allnodes_linklocal(ip6addr) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
in declaration at line 196 *)
(* error
#define ip6_addr_set_allnodes_linklocal(ip6addr) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
(* error
                (ip6addr)->addr[1] = 0; \
in declaration at line 197 *)
(* error
                (ip6addr)->addr[1] = 0; \
(* error
                (ip6addr)->addr[2] = 0; \
in declaration at line 198 *)
(* error
                (ip6addr)->addr[2] = 0; \
(* error
                (ip6addr)->addr[3] = PP_HTONL(0x00000001UL);}while(0
in declaration at line 199 *)
(* error
                (ip6addr)->addr[3] = PP_HTONL(0x00000001UL);}while(0

in define line 204 *)
(* error
#define ip6_addr_set_allrouters_linklocal(ip6addr) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
in declaration at line 205 *)
(* error
#define ip6_addr_set_allrouters_linklocal(ip6addr) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
(* error
                (ip6addr)->addr[1] = 0; \
in declaration at line 206 *)
(* error
                (ip6addr)->addr[1] = 0; \
(* error
                (ip6addr)->addr[2] = 0; \
in declaration at line 207 *)
(* error
                (ip6addr)->addr[2] = 0; \
(* error
                (ip6addr)->addr[3] = PP_HTONL(0x00000002UL);}while(0
in declaration at line 208 *)
(* error
                (ip6addr)->addr[3] = PP_HTONL(0x00000002UL);}while(0

in define line 212 *)
(* error
#define ip6_addr_set_solicitednode(ip6addr, if_id) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
in declaration at line 214 *)
(* error
#define ip6_addr_set_solicitednode(ip6addr, if_id) do{(ip6addr)->addr[0] = PP_HTONL(0xff020000UL); \
(* error
                (ip6addr)->addr[1] = 0; \
in declaration at line 215 *)
(* error
                (ip6addr)->addr[1] = 0; \
(* error
                (ip6addr)->addr[2] = PP_HTONL(0x00000001UL); \
in declaration at line 216 *)
(* error
                (ip6addr)->addr[2] = PP_HTONL(0x00000001UL); \
(* error
                (ip6addr)->addr[3] = (PP_HTONL(0xff000000UL) | (if_id));}while(0
in declaration at line 217 *)
(* error
                (ip6addr)->addr[3] = (PP_HTONL(0xff000000UL) | (if_id));}while(0

in define line 222 *)


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }

function ip6_addr_isinvalid(addr_state: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_istentative(addr_state: longint): longint;


{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isvalid(addr_state: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ispreferred(addr_state: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isdeprecated(addr_state: longint): longint;

(* error
  LWIP_DEBUGF(debug, ("%" X16_F ":%" X16_F ":%" X16_F ":%" X16_F ":%" X16_F ":%" X16_F ":%" X16_F ":%" X16_F, \
in define line 248 *)
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_debug_print(debug, ipaddr: longint): longint;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_debug_print_val(debug, ipaddr: longint): longint;


(* Const before type ignored *)

function ip6addr_aton(cp: PChar; addr: Pip6_addr_t): longint; cdecl; external;

(* Const before type ignored *)
function ip6addr_ntoa(addr: Pip6_addr_t): PChar; cdecl; external;
(* Const before type ignored *)
function ip6addr_ntoa_r(addr: Pip6_addr_t; buf: PChar; buflen: longint): PChar;
  cdecl; external;

}

implementation
{
{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK2(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK2:=Tu16_t((lwip_htonl(ip6addr^.(addr[0]))) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK3(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK3:=Tu16_t(((lwip_htonl(ip6addr^.(addr[1]))) shr 16) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK4(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK4:=Tu16_t((lwip_htonl(ip6addr^.(addr[1]))) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK5(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK5:=Tu16_t(((lwip_htonl(ip6addr^.(addr[2]))) shr 16) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK6(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK6:=Tu16_t((lwip_htonl(ip6addr^.(addr[2]))) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK7(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK7:=Tu16_t(((lwip_htonl(ip6addr^.(addr[3]))) shr 16) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
function IP6_ADDR_BLOCK8(ip6addr: longint): Tu16_t;
begin
  //IP6_ADDR_BLOCK8:=Tu16_t((lwip_htonl(ip6addr^.(addr[3]))) and $ffff);
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_cmp(addr1, addr2: longint): longint;
begin
  //ip6_addr_cmp:=((((addr1^.(addr[0]))=(addr2^.(addr[0]))) and (@((addr1^.(addr[1]))=(addr2^.(addr[1]))))) and (@((addr1^.(addr[2]))=(addr2^.(addr[2]))))) and (@((addr1^.(addr[3]))=(addr2^.(addr[3]))));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_get_subnet_id(ip6addr: longint): longint;
begin
  //ip6_get_subnet_id:=(lwip_htonl(ip6addr^.(addr[2]))) and $0000ffff;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isany_val(ip6addr: longint): longint;
begin
  //ip6_addr_isany_val:=((((ip6addr.(addr[0]))=0) and (@((ip6addr.(addr[1]))=0))) and (@((ip6addr.(addr[2]))=0))) and (@((ip6addr.(addr[3]))=0));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isloopback(ip6addr: longint): longint;
begin
  //ip6_addr_isloopback:=((((ip6addr^.(addr[0]))=0) and (@((ip6addr^.(addr[1]))=0))) and (@((ip6addr^.(addr[2]))=0))) and (@((ip6addr^.(addr[3]))=(PP_HTONL($00000001))));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isglobal(ip6addr: longint): longint;
begin
  //ip6_addr_isglobal:=((ip6addr^.(addr[0])) and (PP_HTONL($e0000000)))=(PP_HTONL($20000000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_islinklocal(ip6addr: longint): longint;
begin
  //ip6_addr_islinklocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ffc00000)))=(PP_HTONL($fe800000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_issitelocal(ip6addr: longint): longint;
begin
  //ip6_addr_issitelocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ffc00000)))=(PP_HTONL($fec00000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isuniquelocal(ip6addr: longint): longint;
begin
  //ip6_addr_isuniquelocal:=((ip6addr^.(addr[0])) and (PP_HTONL($fe000000)))=(PP_HTONL($fc000000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isipv4mappedipv6(ip6addr: longint): longint;
begin
  //ip6_addr_isipv4mappedipv6:=(((ip6addr^.(addr[0]))=0) and (@((ip6addr^.(addr[1]))=0))) and (@((ip6addr^.(addr[2]))=(PP_HTONL($0000FFFF))));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast:=((ip6addr^.(addr[0])) and (PP_HTONL($ff000000)))=(PP_HTONL($ff000000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_transient_flag(ip6addr: longint): longint;
begin
  //ip6_addr_multicast_transient_flag:=(ip6addr^.(addr[0])) and (PP_HTONL($00100000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_prefix_flag(ip6addr: longint): longint;
begin
  //ip6_addr_multicast_prefix_flag:=(ip6addr^.(addr[0])) and (PP_HTONL($00200000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_rendezvous_flag(ip6addr: longint): longint;
begin
  //ip6_addr_multicast_rendezvous_flag:=(ip6addr^.(addr[0])) and (PP_HTONL($00400000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_multicast_scope(ip6addr: longint): longint;
begin
  //ip6_addr_multicast_scope:=((lwip_htonl(ip6addr^.(addr[0]))) shr 16) and $f;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_iflocal(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_iflocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff010000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_linklocal(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_linklocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff020000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_adminlocal(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_adminlocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff040000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_sitelocal(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_sitelocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff050000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_orglocal(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_orglocal:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff080000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ismulticast_global(ip6addr: longint): longint;
begin
  //ip6_addr_ismulticast_global:=((ip6addr^.(addr[0])) and (PP_HTONL($ff8f0000)))=(PP_HTONL($ff0e0000));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isallnodes_iflocal(ip6addr: longint): longint;
begin
  //ip6_addr_isallnodes_iflocal:=((((ip6addr^.(addr[0]))=(PP_HTONL($ff010000))) and (@((ip6addr^.(addr[1]))=0))) and (@((ip6addr^.(addr[2]))=0))) and (@((ip6addr^.(addr[3]))=(PP_HTONL($00000001))));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isallnodes_linklocal(ip6addr: longint): longint;
begin
  //ip6_addr_isallnodes_linklocal:=((((ip6addr^.(addr[0]))=(PP_HTONL($ff020000))) and (@((ip6addr^.(addr[1]))=0))) and (@((ip6addr^.(addr[2]))=0))) and (@((ip6addr^.(addr[3]))=(PP_HTONL($00000001))));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isinvalid(addr_state: longint): longint;
begin
  //ip6_addr_isinvalid:=addr_state=IP6_ADDR_INVALID;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_istentative(addr_state: longint): longint;
begin
  //ip6_addr_istentative:=addr_state and IP6_ADDR_TENTATIVE;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isvalid(addr_state: longint): longint;
begin
  //ip6_addr_isvalid:=addr_state and IP6_ADDR_VALID;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_ispreferred(addr_state: longint): longint;
begin
  //ip6_addr_ispreferred:=addr_state=IP6_ADDR_PREFERRED;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_isdeprecated(addr_state: longint): longint;
begin
  //ip6_addr_isdeprecated:=addr_state=IP6_ADDR_DEPRECATED;
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_debug_print(debug, ipaddr: longint): longint;
var
  if_local1, if_local2, if_local3, if_local4, if_local5, if_local6,
  if_local7, if_local8: longint;
  (* result types are not known *)
begin
  //ip6_addr_debug_print:=ip6_addr_debug_print_parts(debug,Tu16_t(ipaddr<>(if_local1)),Tu16_t(ipaddr<>(if_local2)),Tu16_t(ipaddr<>(if_local3)),Tu16_t(ipaddr<>(if_local4)),Tu16_t(ipaddr<>(if_local5)),Tu16_t(ipaddr<>(if_local6)),Tu16_t(ipaddr<>(if_local7)),Tu16_t(ipaddr<>(if_local8)));
end;

{ was #define dname(params) para_def_expr }
{ argument types are unknown }
{ return type might be wrong }
function ip6_addr_debug_print_val(debug, ipaddr: longint): longint;
begin
  //ip6_addr_debug_print_val:=ip6_addr_debug_print_parts(debug,IP6_ADDR_BLOCK1(@(ipaddr)),IP6_ADDR_BLOCK2(@(ipaddr)),IP6_ADDR_BLOCK3(@(ipaddr)),IP6_ADDR_BLOCK4(@(ipaddr)),IP6_ADDR_BLOCK5(@(ipaddr)),IP6_ADDR_BLOCK6(@(ipaddr)),IP6_ADDR_BLOCK7(@(ipaddr)),IP6_ADDR_BLOCK8(@(ipaddr)));
end;
}
end.
