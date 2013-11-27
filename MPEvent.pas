unit MPEvent;
(*

   MPEVENT.H - Structure and mnemonic identifier declarations for MercuryP events.
   Mercury Mail Transport System, Copyright (c) 1993-2007, David Harris.

   See "MercuryP Events.txt" for descriptions of these events.

   IMPORTANT NOTE: The MPEVENTBUF structure defined in this file may grow over
   time - new fields may be added to reflect new options in MercuryP. New fields
   will, however, always be added at the END of the structure - this ensures that
   existing Daemons do not have to be concerned that the layout at the time they
   are compiled might change.

   What this *does* mean, though, is that your daemons should always check the
   "sversion" field of the structure and be extra cautious if the version
   reported by Mercury is older than the version in existence at the time you
   developed your code.

*)
interface
//#ifndef _MPEVENT_H_
//#define _MPEVENT_H_
type
(***********************************************
  Define some standard scalar types, if they
  haven't already been defined somewhere else.
************************************************)
//#ifndef INTS_DEFINED
//#define INTS_DEFINED

////typedef unsigned char   UCHAR;

  PUchar = ^TUchar;
  {$EXTERNALSYM UCHAR}
  UCHAR = Byte;
  TUchar = Byte;
////typedef unsigned short  USHORT;

  PUshort = ^TUshort;
  {$EXTERNALSYM USHORT}
  USHORT = Word;
  TUshort = Word;
////typedef unsigned long   ULONG;

  PUlong = ^TUlong;
  {$EXTERNALSYM ULONG}
  ULONG = Longword;
  TUlong = Longword;
////typedef unsigned short  UINT_16;

  PUint16 = ^TUint16;
  {$EXTERNALSYM UINT_16}
  UINT_16 = Word;
  TUint16 = Word;
////typedef short           INT_16;

  PInt16 = ^TInt16;
  {$EXTERNALSYM INT_16}
  INT_16 = Smallint;
  TInt16 = Smallint;
////typedef unsigned long   UINT_32;

  PUint32 = ^TUint32;
  {$EXTERNALSYM UINT_32}
  UINT_32 = Longword;
  TUint32 = Longword;
////typedef long            INT_32;

  PInt32 = ^TInt32;
  {$EXTERNALSYM INT_32}
  INT_32 = Longint;
  TInt32 = Longint;

//#endif      //  INTS_DEFINED
(**********************************************)
const
  {$EXTERNALSYM MPE_CURRENT_VERSION}
  MPE_CURRENT_VERSION                 = $10003; 

//  The following defines are used to form the control word ("ucw")
//  MercuryP creates for each user on connection. The control word
//  determines what messages should be shown, whether they should
//  be flagged as read when downloaded and so forth.

  {$EXTERNALSYM SHOW_READ}
  SHOW_READ                           = 1; 
  {$EXTERNALSYM MARK_READ}
  MARK_READ                           = 2; 
  {$EXTERNALSYM SHOW_STATUS}
  SHOW_STATUS                         = 4; 
  {$EXTERNALSYM NO_DELETE}
  NO_DELETE                           = 8; 
  {$EXTERNALSYM DELETE_IS_FINAL}
  DELETE_IS_FINAL                     = 16; 

//  The next group of defines are used to form the "sucw" login-time
//  constraint control word for the connection: these constraints are
//  applied by MercuryP when it builds the mailbox list that will be
//  presented to the user, and are typically appended by the user to
//  his username at login-time.

  {$EXTERNALSYM S_SHOW_UNREAD}
  S_SHOW_UNREAD                       = 1; 
  {$EXTERNALSYM S_SHOW_NEW}
  S_SHOW_NEW                          = 2; 
  {$EXTERNALSYM S_SHOW_URGENT}
  S_SHOW_URGENT                       = 4; 
  {$EXTERNALSYM S_FROM_TEST}
  S_FROM_TEST                         = 8; 
  {$EXTERNALSYM S_OMIT_TEST}
  S_OMIT_TEST                         = 16; 
  {$EXTERNALSYM S_SHOW_TEST}
  S_SHOW_TEST                         = 32; 
  {$EXTERNALSYM S_SUBJECT_TEST}
  S_SUBJECT_TEST                      = 64; 
  {$EXTERNALSYM S_SINCE_TEST}
  S_SINCE_TEST                        = 128; 
  {$EXTERNALSYM S_SINCE2_TEST}
  S_SINCE2_TEST                       = 256; 

//  MPEVT_* constants are the IDs for the events MercuryP can generate
//  in the course of a transaction: see "MercuryP Events.txt": for full
//  descriptions of each event and its possible responses.

  {$EXTERNALSYM MPEVT_CONNECT}
  MPEVT_CONNECT                       = 1; 
  {$EXTERNALSYM MPEVT_CONNECT2}
  MPEVT_CONNECT2                      = 2; 
  {$EXTERNALSYM MPEVT_PROFILE}
  MPEVT_PROFILE                       = 3; 
  {$EXTERNALSYM MPEVT_LOGIN}
  MPEVT_LOGIN                         = 4; 
  {$EXTERNALSYM MPEVT_APOP}
  MPEVT_APOP                          = 5; 
  {$EXTERNALSYM MPEVT_AUTH_OTHER}
  MPEVT_AUTH_OTHER                    = 6; 
  {$EXTERNALSYM MPEVT_COMMAND}
  MPEVT_COMMAND                       = 7; 
  {$EXTERNALSYM MPEVT_COMMAND2}
  MPEVT_COMMAND2                      = 8; 
  {$EXTERNALSYM MPEVT_MBSCAN}
  MPEVT_MBSCAN                        = 9; 
  {$EXTERNALSYM MPEVT_MBITEM}
  MPEVT_MBITEM                        = 10; 
  {$EXTERNALSYM MPEVT_RETR}
  MPEVT_RETR                          = 11; 
  {$EXTERNALSYM MPEVT_RSET}
  MPEVT_RSET                          = 12; 
  {$EXTERNALSYM MPEVT_RSET2}
  MPEVT_RSET2                         = 13; 
  {$EXTERNALSYM MPEVT_DELETE}
  MPEVT_DELETE                        = 14; 
  {$EXTERNALSYM MPEVT_CLOSE}
  MPEVT_CLOSE                         = 20; 

(*
  MPEVENTBUF structures are the usual parameter passed when an event
  occurs in MercuryP. Daemons must pay particular attention to the
  "sversion" member: this is divided into a major version number in the
  high word, and a minor version number in the low word. If a Daemon
  encounters a version where the major version number is different from
  the version for which it was compiled, it must not attempt to access
  the structure. If the major version is the same as the version for
  which the Daemon was compiled, it should examine the minor version
  to decide how to proceed: if the minor version is lower than the
  version for which it was compiled, it may access the structure,
  provided it does not attempt to access fields not present in the
  version supported by the structure. If the minor version is equal to
  or higher than the version for which it was compiled, it may proceed
  without restriction - the structure layout it understands is
  guaranteed to be present.

  Associating data with a transaction: a Daemon may need to store data
  internally in order to track the progress of a job as it passes through
  the various event states. The best way to do this is to build a table
  of data structures indexed on the "trans_id" field of the MPEVENTBUF
  MercuryP passes you, then to look up the data on each event; the
  "trans_id" field is guaranteed to be unique for the current Mercury
  session, although it will not survive a restart.  A Daemon that needs
  to store state information in this way should look for the
  MPEVT_DISCONNECT event, which marks the end of the transaction, and
  tidy up any allocations or data structures at that time.

  Getting and setting message headers: a Daemon can add headers to a
  retrieved message any time up to the MPEVT_DATA_BODY event. To add a
  header, use the "mp_add_header" function in the MPEVENTBUF's "functions"
  structure, passing the MPEVENTBUF's "reserved" member as the parameter.
  The header must be fully-formed. Note that the header is only added to
  the downloaded copy of the message - the original message on the server
  is not actually modified by this action. The intent is to allow headers
  to be dynamically injected for clients at download time.

  To examine the current value of an added header, use the "mp_get_header"
  function in the MPEVENTBUF's "functions" structure; note that this
  function can ONLY examine headers that have been added - you cannot use
  this function to examine headers that are already in the message. You
  can, however, see the headers added by any Daemon using this function -
  not just those you have added yourself. The "mp_get_all_headers" function
  returns all the headers currently marked for addition to the message as
  a single block, each header terminated with CR/LF endings. Passing NULL
  as the "buffer" parameter for this function will return the size of the
  buffer required to accommodate the block of headers. Headers defined
  using these functions are injected into the download immediately after
  the MPEVT_DATA_BODY event is generated.
*)

//typedef INT_32 (*MP_ADD_HEADER)  (UINT_32 reserved, char *header, INT_32 allow_dupes);_
//typedef INT_32 (*MP_GET_HEADER)  (UINT_32 reserved, char *name, char *buffer, INT_32 buflen);
//typedef INT_32 (*MP_GET_ALL_HEADERS) (UINT_32 reserved, char *buffer, INT_32 buflen);
//typedef INT_32 (*MP_READLINE) (UINT_32 reserved, char *buffer, INT_32 buflen);
//typedef INT_32 (*MP_WRITELINE) (UINT_32 reserved, char *buffer);
//typedef INT_32 (*MP_CONSOLETEXT) (UINT_32 reserved, char *text);
//typedef INT_32 (*MP_LOGGINGTEXT) (UINT_32 reserved, char errcode, char *text);
//typedef INT_32 (*MP_GETMESSAGE) (UINT_32 reserved, INT_32 msgnum, char *fname);
//typedef INT_32 (*MP_GETMESSAGEID) (UINT_32 reserved, INT_32 msgnum, char *uid);
//typedef INT_32 (*MP_GETMESSAGEBYID) (UINT_32 reserved, char *uid);
//typedef INT_32 (*MP_GETMESSAGEDATEHASH) (UINT_32 reserved, int msgnum, UINT_32 *hash);

type

////INT_32 MP_ADD_HEADER  (UINT_32 reserved, char *header, INT_32 allow_dupes);

{$EXTERNALSYM MP_ADD_HEADER}
  MP_ADD_HEADER = function (reserved: UINT_32; header: PAnsiChar; allow_dupes: INT_32): INT_32; cdecl;

////INT_32 MP_GET_HEADER  (UINT_32 reserved, char *name, char *buffer, INT_32 buflen);

{$EXTERNALSYM MP_GET_HEADER}
  MP_GET_HEADER = function (reserved: UINT_32; name: PAnsiChar; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;

////INT_32 MP_GET_ALL_HEADERS (UINT_32 reserved, char *buffer, INT_32 buflen);

{$EXTERNALSYM MP_GET_ALL_HEADERS}
  MP_GET_ALL_HEADERS = function (reserved: UINT_32; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;

////INT_32 MP_READLINE (UINT_32 reserved, char *buffer, INT_32 buflen);

{$EXTERNALSYM MP_READLINE}
  MP_READLINE = function (reserved: UINT_32; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;

////INT_32 MP_WRITELINE (UINT_32 reserved, char *buffer);

{$EXTERNALSYM MP_WRITELINE}
  MP_WRITELINE = function (reserved: UINT_32; buffer: PAnsiChar): INT_32; cdecl;

////INT_32 MP_CONSOLETEXT (UINT_32 reserved, char *text);

{$EXTERNALSYM MP_CONSOLETEXT}
  MP_CONSOLETEXT = function (reserved: UINT_32; text: PAnsiChar): INT_32; cdecl;

////INT_32 MP_LOGGINGTEXT (UINT_32 reserved, char errcode, char *text);

{$EXTERNALSYM MP_LOGGINGTEXT}
  MP_LOGGINGTEXT = function (reserved: UINT_32; errcode: AnsiChar; text: PAnsiChar): INT_32; cdecl;

////INT_32 MP_GETMESSAGE (UINT_32 reserved, INT_32 msgnum, char *fname);

{$EXTERNALSYM MP_GETMESSAGE}
  MP_GETMESSAGE = function (reserved: UINT_32; msgnum: INT_32; fname: PAnsiChar): INT_32; cdecl;

////INT_32 MP_GETMESSAGEID (UINT_32 reserved, INT_32 msgnum, char *uid);

{$EXTERNALSYM MP_GETMESSAGEID}
  MP_GETMESSAGEID = function (reserved: UINT_32; msgnum: INT_32; uid: PAnsiChar): INT_32; cdecl;

////INT_32 MP_GETMESSAGEBYID (UINT_32 reserved, char *uid);

{$EXTERNALSYM MP_GETMESSAGEBYID}
  MP_GETMESSAGEBYID = function (reserved: UINT_32; uid: PAnsiChar): INT_32; cdecl;

////INT_32 MP_GETMESSAGEDATEHASH (UINT_32 reserved, int msgnum, UINT_32 *hash);

{$EXTERNALSYM MP_GETMESSAGEDATEHASH}
  MP_GETMESSAGEDATEHASH = function (reserved: UINT_32; msgnum: Integer; var hash: UINT_32): INT_32; cdecl;


////typedef struct
////   {
////   MP_ADD_HEADER mp_add_header;
////   MP_GET_HEADER mp_get_header;
////   MP_GET_ALL_HEADERS mp_get_all_headers;
////   MP_READLINE mp_readline;
////   MP_WRITELINE mp_writeline;
////   MP_CONSOLETEXT mp_consoletext;
////   MP_LOGGINGTEXT mp_loggingtext;
////   MP_GETMESSAGE mp_getmessage;
////   MP_GETMESSAGEID mp_getmessageid;
////   MP_GETMESSAGEBYID mp_getmessagebyid;
////   MP_GETMESSAGEDATEHASH mp_getmessagedatehash;
////   } MP_EBFNS;

  PMpEbfns  = ^TMpEbfns;
  PMP_EBFNS = PMpEbfns;
  {$EXTERNALSYM MP_EBFNS}
  MP_EBFNS = packed record
    mp_add_header: MP_ADD_HEADER;
    mp_get_header: MP_GET_HEADER;
    mp_get_all_headers: MP_GET_ALL_HEADERS;
    mp_readline: MP_READLINE;
    mp_writeline: MP_WRITELINE;
    mp_consoletext: MP_CONSOLETEXT;
    mp_loggingtext: MP_LOGGINGTEXT;
    mp_getmessage: MP_GETMESSAGE;
    mp_getmessageid: MP_GETMESSAGEID;
    mp_getmessagebyid: MP_GETMESSAGEBYID;
    mp_getmessagedatehash: MP_GETMESSAGEDATEHASH;
  end;
  TMpEbfns = MP_EBFNS;

////typedef struct
////   {
////   UINT_32   sversion;        //  Version of this structure
////   UINT_32   ssize;           //  Total length in bytes of this structure
////   UINT_32   reserved;        //  Daemons *must not* alter this field.
////
////   MP_EBFNS  *functions;      //  A block of Daemon-callable utility functions
////
////   INT_32    state;           //  Current state machine transaction state
////   UINT_32   flags;           //  State information about the transaction
////   UINT_32   aclflags;        //  Access control flags for the transaction
////   INT_32    start_time;      //  Time of initial connection (actually a time_t)
////   UINT_32   trans_id;        //  Transaction ID - unique during this session
////   INT_32    port;            //  The port on which the peer is connected
////   char      *client;         //  The peer's IP address in string form
////   char      uic [256];       //  User name or identity of authenticated user
////   char      mailbox [256];   //  User's mailbox directory
////   UINT_32   ucw;             //  User-profile control word.
////   UINT_32   tsize;           //  Total size of presented maildrop contents
////   UINT_32   count;           //  Number of messages in presented maildrop
////   INT_32    inbuflen;        //  The maximum allocated length of "inbuf"
////   char      *inbuf;          //  Event-specific
////   char      outbuf [1024];   //  Event-specific
////   UINT_32   iparam;          //  Event-specific integer parameter
////   char      *sparam;         //  Event-specific C string parameter
////   UINT_32   sucw;            //  Session-specific user-profile control word.
////   UINT_32   test_size;       //  Allocated size of following "*_test" fields
////   char      *from_test;      //  User's login-time "From" test if any
////   char      *omit_test;      //  User's login-time "Omit" test if any
////   char      *show_test;      //  User's login-time "Show" test if any
////   char      *subject_test;   //  User's login-time "Show" test if any
////   BYTE      *since;          //  User's login-time "Since" test if any (8 bytes)
////   UINT_32   since2;          //  User's login-time "Since2" test if any
////   char      *apop_challenge; //  APOP challenge string issued at connect time
////   } MPEVENTBUF;
type
  PMPEventBuf = ^TMPEventBuf;
  {$EXTERNALSYM MPEVENTBUF}
  MPEVENTBUF = packed record
    sversion: UINT_32;                    //  Version of this structure
    ssize: UINT_32;                       //  Total length in bytes of this structure
    reserved: UINT_32;                    //  Daemons *must not* alter this field.
    functions: PMP_EBFNS;                 //  A block of Daemon-callable utility functions
    state: INT_32;                        //  Current state machine transaction state
    flags: UINT_32;                       //  State information about the transaction
    aclflags: UINT_32;                    //  Access control flags for the transaction
    start_time: INT_32;                   //  Time of initial connection (actually a time_t)
    trans_id: UINT_32;                    //  Transaction ID - unique during this session
    port: INT_32;                         //  The port on which the peer is connected
    client: PAnsiChar;                    //  The peer's IP address in string form
    uic: array[0..255] of AnsiChar;       //  User name or identity of authenticated user
    mailbox: array[0..255] of AnsiChar;   //  User's mailbox directory
    ucw: UINT_32;                         //  User-profile control word.
    tsize: UINT_32;                       //  Total size of presented maildrop contents
    count: UINT_32;                       //  Number of messages in presented maildrop
    inbuflen: INT_32;                     //  The maximum allocated length of "inbuf"
    inbuf: PAnsiChar;                     //  Event-specific
    outbuf: array[0..1023] of AnsiChar;   //  Event-specific
    iparam: UINT_32;                      //  Event-specific integer parameter
    sparam: PAnsiChar;                    //  Event-specific C string parameter
    sucw: UINT_32;                        //  Session-specific user-profile control word.
    test_size: UINT_32;                   //  Allocated size of following "*_test" fields
    from_test: PAnsiChar;                 //  User's login-time "From" test if any
    omit_test: PAnsiChar;                 //  User's login-time "Omit" test if any
    show_test: PAnsiChar;                 //  User's login-time "Show" test if any
    subject_test: PAnsiChar;              //  User's login-time "Show" test if any
    since: PByte;                         //  User's login-time "Since" test if any (8 bytes)
    since2: UINT_32;                      //  User's login-time "Since2" test if any
    apop_challenge: PAnsiChar;           //  APOP challenge string issued at connect time
  end;
  TMPEventBuf = MPEVENTBUF;


////INT_32 eb_initialize (MP_EBFNS *ebfns);

//{$EXTERNALSYM eb_initialize}
// function eb_initialize(ebfns: PMP_EBFNS): INT_32; cdecl; external '???';


//#endif   // _MPEVENT_H_

implementation

end.
