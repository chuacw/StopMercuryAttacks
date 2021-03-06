// chuacw
unit Mercury.SMTP.Events;

{$RTTI EXPLICIT METHODS([]) PROPERTIES([]) FIELDS([])}
{$WEAKLINKRTTI ON}

(*

   MSEVENT.H - Structure and mnemonic identifier declarations for MercuryS events.
   Mercury Mail Transport System, Copyright (c) 1993-2005, David Harris.

   See "MercuryS Events.txt" for descriptions of these events.

   IMPORTANT NOTE: The MSEVENTBUF structure defined in this file may grow over
   time - new fields may be added to reflect new options in MercuryS. New fields
   will, however, always be added at the END of the structure - this ensures that
   existing Daemons do not have to be concerned that the layout at the time they
   are compiled might change.

   What this *does* mean, though, is that your daemons should always check the
   "sversion" field of the structure and be extra cautious if the version
   reported by Mercury is older than the version in existence at the time you
   developed your code.

*)

//#ifndef _MSEVENT_H_
//#define _MSEVENT_H_


(***********************************************
  Define some standard scalar types, if they
  haven't already been defined somewhere else.
************************************************)
//#ifndef INTS_DEFINED
//#define INTS_DEFINED
interface
type

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
// typedef short           INT_16;

  PInt16 = ^TInt16;
  {$EXTERNALSYM INT_16}
  INT_16 = Smallint;
  TInt16 = Smallint;
// typedef unsigned long   UINT_32;

  PUint32 = ^TUint32;
  {$EXTERNALSYM UINT_32}
  UINT_32 = Longword;
  TUint32 = Longword;
// typedef long            INT_32;

  PInt32 = ^TInt32; 
  {$EXTERNALSYM INT_32} 
  INT_32 = Longint; 
  TInt32 = Longint;

//#endif      //  INTS_DEFINED
(**********************************************)

const
//  MSEVT_* constants are the IDs for the events MercuryS can generate
//  in the course of a transaction: see "MercuryS Events.txt": for full
//  descriptions of each event and its possible responses.

  {$EXTERNALSYM MSEVT_CONNECT}
///<summary>MercuryS generates this event when it receives a connection, but
/// before any data is read or written. The parameter is a standard
/// EVENTBUF structure where "port" is the port on which the peer
/// established the connection, and "client" is a string representation of
/// the IP address of the connecting peer (e.g, "192.156.225.1"). When
/// this event is generated, no other field in the MSEVENTBUF is defined.

/// An event handler can return -2 to tell MercuryS to close the
/// connection immediately without further processing. In this case, if
/// the "outbuf" member of the EVENTBUF structure is not an empty string
/// on return, MercuryS will write it to the socket before closing it down
/// - it is the event handler's job to format the response correctly,
/// including a proper RFC2821 400- or 500- series error code.

/// An event handler can return -3 to tell MercuryS that it should
/// terminate the connection, and add the peer's IP address to its
/// internal short-term blacklist. The "outbuf" parameter is handled the
/// same in this case as it is for a return of -1.
/// An event handler can return 1 to tell MercuryS that it should suppress
///   all transaction-level filtering rules of all types for this connection.
///</summary>
  MSEVT_CONNECT                       = 1;
  {$EXTERNALSYM MSEVT_CONNECT2}
/// <summary>
/// MercuryS generates this event when it receives a connection, before
/// any data is read or written, but after it has completed its own access
/// control tests (specifically blacklist and ACL checking). The parameter
/// is a standard EVENTBUF structure where "port" is the port on which the
/// peer established the connection, and "client" is a string
/// representation of the IP address of the connecting peer (e.g,
/// "192.156.225.1"). When this event is generated, no other field in the
/// MSEVENTBUF is defined.

/// An event handler can return -2 to tell MercuryS to close the
/// connection immediately without further processing. In this case, if
/// the "outbuf" member of the EVENTBUF structure is not an empty string
/// on return, MercuryS will write it to the socket before closing it down
/// - it is the event handler's job to format the response correctly,
/// including a proper RFC2821 400- or 500- series error code.

/// An event handler can return -3 to tell MercuryS that it should
/// terminate the connection, and add the peer's IP address to its
/// internal short-term blacklist. The "outbuf" parameter is handled the
/// same in this case as it is for a return of -1.

/// An event handler can return 1 to tell MercuryS that it should suppress
/// all transaction-level filtering rules of all types for this connection.
/// </summary>
  MSEVT_CONNECT2                      = 13;
  {$EXTERNALSYM MSEVT_HELO}
///<summary>
///    MercuryS generates this event when it receives a HELO or EHLO command
///    from the connected peer. The "inbuf" field in the EVENTBUF parameter
///    contains the unmodified HELO/EHLO command exactly as it was received.
///    The event handler can modify this field if it wishes - the event is
///    generated before MercuryS actually examines the parameter itself, so
///    if the handler modifies the parameter, MercuryS will process the
///    modified version.
///
///    An event handler can return -2 to tell MercuryS to fail the command
///    and close the connection immediately without further processing. In
///    this case, if the "outbuf" member of the EVENTBUF structure is not an
///    empty string on return, MercuryS will write it to the socket before
///    closing it down - it is the event handler's job to format the response
///    correctly, including a proper RFC2821 400- or 500- series error code.
///
///    An event handler can return -3 to tell MercuryS that it should fail
///    the command, terminate the connection, and add the peer's IP address
///    to its internal short-term blacklist. The "outbuf" parameter is
///    handled the same in this case as it is for returns of -1 or -2.
///
///    An event handler can return 1 to tell MercuryS that it should suppress
///    all transaction-level HELO filtering rules for this connection.
///</summary>
  MSEVT_HELO                          = 2;
  {$EXTERNALSYM MSEVT_ESMTP_AUTH}
  MSEVT_ESMTP_AUTH                    = 11;
  {$EXTERNALSYM MSEVT_ESMTP_END}
  MSEVT_ESMTP_END                     = 12;
  {$EXTERNALSYM MSEVT_AUTH}
///<summary>
/// This event is generated when MercuryS receives an AUTH command from
/// the connected peer. The "inbuf" field in the EVENTBUF parameter
/// contains the unmodified AUTH command exactly as it was received. The
/// event handler can modify this field if it wishes - the event is
/// generated before MercuryS actually examines the parameter itself, so
/// if the handler modifies the parameter, MercuryS will process the
/// modified version.

/// An event handler can return 1 to MercuryS to indicate that the
/// connection has been successfully authenticated. In this instance, if
/// "outbuf" is not zero-length, it will be used as the success response
/// to the command, otherwise, MercuryS will revert to its OPEN state and
/// continue processing.

/// An event handler can return -1 to tell MercuryS fail the command. In
/// this case, if the "outbuf" member of the EVENTBUF structure is not an
/// empty string on return, MercuryS will write it to the socket - it is
/// the event handler's job to format the response correctly, including a
/// proper RFC2821 400- or 500- series error code. If the "outbuf" member
/// is zero-length, MercuryS will generate a standard 500-series error
/// response. This response does not terminate the connection - the peer
/// can, if it wishes, attempt to issue other commands.

/// An event handler can return -2 to tell MercuryS that it should both
/// fail the command, and terminate the connection. As with the -1 return,
/// the "outbuf" member of the parameter can be set to an error message to
/// return to the peer, with MercuryS generating a reasonable default if
/// it is zero-length.

/// An event handler can return -3 to tell MercuryS that it should fail
/// the command, terminate the connection, and add the peer's IP address
/// to its internal short-term blacklist. The "outbuf" parameter is
/// handled the same in this case as it is for returns of -1 or -2.
///</summary>
  MSEVT_AUTH                          = 10;
  {$EXTERNALSYM MSEVT_COMMAND}
  MSEVT_COMMAND                       = 14;
  {$EXTERNALSYM MSEVT_RSET}
  MSEVT_RSET                          = 17;
  {$EXTERNALSYM MSEVT_MAIL}

///<summary>
/// MercuryS generates this event when it receives a MAIL FROM: command
/// from the connected peer. The "inbuf" field in the EVENTBUF parameter
/// contains the full, unmodified contents of the MAIL FROM: command -
/// the event handler can modify this field if it wishes: the event is
/// generated before MercuryS actually examines the parameter itself, so
/// if the handler modifies the parameter, MercuryS will process the
/// modified version.
///
/// An event handler can return -1 to tell MercuryS fail the command. In
/// this case, if the "outbuf" member of the EVENTBUF structure is not an
/// empty string on return, MercuryS will write it to the socket - it is
/// the event handler's job to format the response correctly, including a
/// proper RFC2821 400- or 500- series error code. If the "outbuf" member
/// is zero-length, MercuryS will generate a standard 500-series error
/// response. This response does not terminate the connection - the peer
/// can, if it wishes, attempt to issue another MAIL FROM: command.
///
/// An event handler can return -2 to tell MercuryS that it should both
/// fail the command, and terminate the connection. As with the -1 return,
/// the "outbuf" member of the parameter can be set to an error message to
/// return to the peer, with MercuryS generating a reasonable default if
/// it is zero-length.
///
/// An event handler can return -3 to tell MercuryS that it should fail
/// the command, terminate the connection, and add the peer's IP address
/// to its internal short-term blacklist. The "outbuf" parameter is
/// handled the same in this case as it is for returns of -1 or -2.
///
/// An event handler can return 1 to tell MercuryS that it should suppress
/// all transaction-level MAIL filtering rules for this connection.
///</summary>
  MSEVT_MAIL                          = 3;
  {$EXTERNALSYM MSEVT_MAIL_OK}
///<summary>
/// MercuryS generates this message once it has parsed the MAIL FROM:
/// command received from the connected peer. If the MAIL FROM: command
/// has an ESMTP "SIZE" declaration, the "msize" member of the MSEVENTBUF
/// parameter will reflect that declaration from this point on. The
/// "return_path" member of the structure will contain the fully reduced
/// and parsed version of the address from the MAIL FROM: command from
/// the time this message is generated onwards. The contents of the
/// "inbuf" field are undefined during this message, and the field should
/// be neither inspected nor altered.
///
/// This message is generated immediately before MercuryS creates the
/// queue job for the transaction, and is intended as a kind of "final
/// check" on the sender's address.
///
/// Event handlers can respond to this event in the same ways and with the
/// same effects as defined for the MSEVT_MAIL event (see above).
/// </summary>
  MSEVT_MAIL_OK                       = 4;
  {$EXTERNALSYM MSEVT_RCPT}
  MSEVT_RCPT                          = 5; 
  {$EXTERNALSYM MSEVT_RCPT_OK}
  MSEVT_RCPT_OK                       = 6; 
  {$EXTERNALSYM MSEVT_DATA}
  MSEVT_DATA                          = 7; 
  {$EXTERNALSYM MSEVT_DATA_HEADER}
  MSEVT_DATA_HEADER                   = 8; 
  {$EXTERNALSYM MSEVT_DATA_BODY}
  MSEVT_DATA_BODY                     = 9; 
  {$EXTERNALSYM MSEVT_CLOSE}
  MSEVT_CLOSE                         = 15; 
  {$EXTERNALSYM MSEVT_ABORT}
  MSEVT_ABORT                         = 16;

//  MSEF_* constants are used to isolate status bits in the "flags" field
//  of MSEVENTBUF structures (see below)

  {$EXTERNALSYM MSEF_AUTHENTICATED}
  MSEF_AUTHENTICATED                  = 1;  //  The peer has issued a successful AUTH command
  {$EXTERNALSYM MSEF_BLOCKED}
  MSEF_BLOCKED                        = 2;  //  Connection is in a "quit-only" blocked state
  {$EXTERNALSYM MSEF_REDIRECTED}
  MSEF_REDIRECTED                     = 4;  //  Connection has been diverted - RCPTS are ignored
  {$EXTERNALSYM MSEF_DATA_REJECTION}
  MSEF_DATA_REJECTION                 = 8;  //  The message is being discarded for policy violations
  {$EXTERNALSYM MSEF_DISKERROR}
  MSEF_DISKERROR                      = $10;  //  A disk error occurred during DATA processing
  {$EXTERNALSYM MSEF_EXEMPT_COMPLIANCE}
  MSEF_EXEMPT_COMPLIANCE              = $20;  //  The message was exempt from compliance processing
  {$EXTERNALSYM MSEF_ESMTP}
  MSEF_ESMTP                          = $40;  //  Connected peer issued an ESTMP EHLO greeting
  {$EXTERNALSYM MSEF_EIGHTBIT}
  MSEF_EIGHTBIT                       = $80;  //  Connected peer issued MAIL FROM with EIGHTBITMIME
  {$EXTERNALSYM MSEF_DEFERRED_HELO}
  MSEF_DEFERRED_HELO                  = $100;  //  Seen HELO, allowing AUTH opportunity before refiltering
  {$EXTERNALSYM MSEF_BLESSED}
  MSEF_BLESSED                        = $200;  //  Connection has been blessed by a transaction filter
  {$EXTERNALSYM MSEF_AUTOLOG}
  MSEF_AUTOLOG                        = $40000000;  //  Reserved for internal use

(*
  MSEVENTBUF structures are the usual parameter passed when an event
  occurs in MercuryS. Daemons must pay particular attention to the
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
  of data structures indexed on the "trans_id" field of the MSEVENTBUF
  MercuryS passes you, then to look up the data on each event; the
  "trans_id" field is guaranteed to be unique for the current Mercury
  session, although it will not survive a restart.  A Daemon that needs
  to store state information in this way should look for the
  MSEVT_DISCONNECT event, which marks the end of the transaction, and
  tidy up any allocations or data structures at that time.

  Getting and setting message headers: a Daemon can add headers to an
  incoming job any time up to the MSEVT_DATA_BODY event. To add a header,
  use the "add_header" function in the MSEVENTBUF's "functions" structure,
  passing the MSEVENTBUF's "reserved" member as the parameter. The header
  must be fully-formed. To examine the current value of an added header,
  use the "get_header" function in the MSEVENTBUF's "functions" structure;
  note that this function can ONLY examine headers that have been added -
  you cannot use this function to examine headers that are already in the
  message. You can, however, see the headers added by any Daemon using
  this function - not just those you have added yourself. The
  "get_all_headers" function returns all the headers currently marked for
  addition to the message as a single block, each header terminated with
  CR/LF endings. Passing NULL as the "buffer" parameter for this function
  will return the size of the buffer required to accommodate the block of
  headers. Headers defined using these functions are added immediately
  after the MSEVT_DATA_BODY event is generated (so, it is not possible to
  add headers based on information found in the message body during
  reception).
*)

const
  {$EXTERNALSYM MSE_CURRENT_VERSION}
  MSE_CURRENT_VERSION                 = $10003;

{$MESSAGE WARN 'Convert the following!!!'}
//typedef INT_32 (*ADD_HEADER)  (UINT_32 reserved, char *header, INT_32 allow_dupes);
//typedef INT_32 (*GET_HEADER)  (UINT_32 reserved, char *name, char *buffer, INT_32 buflen);
//typedef INT_32 (*GET_ALL_HEADERS) (UINT_32 reserved, char *buffer, INT_32 buflen);
//typedef INT_32 (*READLINE) (UINT_32 reserved, char *buffer, INT_32 buflen);
//typedef INT_32 (*WRITELINE) (UINT_32 reserved, char *buffer);
//typedef INT_32 (*CONSOLETEXT) (UINT_32 reserved, char *text);
//typedef INT_32 (*LOGGINGTEXT) (UINT_32 reserved, char errcode, char *text);

type
  ADD_HEADER      = function(reserved: UINT_32; header: PAnsiChar; allow_dupes: INT_32): INT_32; cdecl;
  GET_HEADER      = function(reserved: UINT_32; name: PAnsiChar; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;
  GET_ALL_HEADERS = function(reserved: UINT_32; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;
  READLINE        = function(reserved: UINT_32; buffer: PAnsiChar; buflen: INT_32): INT_32; cdecl;
  WRITELINE       = function(reserved: UINT_32; buffer: PAnsiChar): INT_32; cdecl;
  CONSOLETEXT     = function(reserved: UINT_32; text: PAnsiChar): INT_32; cdecl;
  LOGGINGTEXT     = function(reserved: UINT_32; errcode: AnsiChar; text: PAnsiChar): INT_32; cdecl;

////typedef struct
////   {
////   ADD_HEADER add_header;
////   GET_HEADER get_header;
////   GET_ALL_HEADERS get_all_headers;
////   READLINE readline;
////   WRITELINE writeline;
////   CONSOLETEXT consoletext;
////   LOGGINGTEXT loggingtext;
////   } EBFNS;
type
  PEbfns = ^TEbfns;
  {$EXTERNALSYM EBFNS}
  EBFNS = packed record
    add_header: ADD_HEADER;
    get_header: GET_HEADER;
    get_all_headers: GET_ALL_HEADERS; 
    readline: READLINE; 
    writeline: WRITELINE; 
    consoletext: CONSOLETEXT;
    loggingtext: LOGGINGTEXT;
  end; 
  TEbfns = EBFNS;

////typedef struct
////   {
////   UINT_32   sversion;        //  Version of this structure
////   UINT_32   ssize;           //  Total length in bytes of this structure
////   UINT_32   reserved;        //  Daemons *must not* alter this field.
////
////   EBFNS     *functions;      //  A block of Daemon-callable utility functions
////
////   UINT_32   flags;           //  State information about the transaction
////   INT_32    start_time;      //  Time of initial connection (actually a time_t)
////   UINT_32   trans_id;        //  Transaction ID - unique during this session
////   INT_32    port,            //  The port on which the peer is connected
////             msize;           //  The declared size of the message (0 for none)
////   char      *client;         //  The peer's IP address in string form
////   INT_32    rplen;           //  Maximum allocated length of "return_path"
////   char      *return_path;    //  Address specified in MAIL FROM: command
////   INT_32    rcpts;           //  Total RCPTs accepted so far in this session
////   INT_32    bad_rcpts;       //  Total RCPTs failed so far in this session
////   INT_32    relay_attempts;  //  Total number of attempted relaying operations
////   INT_32    discard_reason;  //  If "flags & MSEF_DATA_REJECTION", the reason code
////   INT_32    inbuflen;        //  The maximum allocated length of "inbuf"
////   char      *inbuf;          //  Event-specific
////   char      outbuf [1024];   //  Event-specific
////   INT_32    bad_cmds;        //  1.03: Total failed commands this session
////   } MSEVENTBUF;

  PMSEventBuf = ^TMSEventBuf;
  {$EXTERNALSYM MSEVENTBUF} 
  ///<summary>Event Buffer</summary>
  MSEVENTBUF = packed record
    ///<summary>Version of this structure</summary>
    sversion: UINT_32;                    //  Version of this structure
    ///<summary>Total length in bytes of this structure</summary>
    ssize: UINT_32;                       //  Total length in bytes of this structure
    ///<summary>Reserved - Daemons *must not* alter this field.</summary>
    reserved: UINT_32;                    //  Daemons *must not* alter this field.
    ///<summary>A block of Daemon-callable utility functions</summary>
    functions: PEBFNS;                    //  A block of Daemon-callable utility functions
    ///<summary>State information about the transaction. The "flags" field is a bitmap that records certain information about the
    /// transaction in progress - for instance, whether or not the peer has issued a successful AUTH command. Unless explicitly noted below, event
    /// handlers should generally regard this field as read-only. The bits in
    /// "flags" can be isolated using the MSEF_* constants declared in MSEVENT.</summary>
    flags: UINT_32;                       //  State information about the transaction
    ///<summary>Time of initial connection (actually a time_t)</summary>
    start_time: INT_32;                   //  Time of initial connection (actually a time_t)
    ///<summary>Transaction ID - unique during this session </summary>
    trans_id: UINT_32;                    //  Transaction ID - unique during this session
    ///<summary>The port on which the peer is connected</summary>
    port: INT_32;                         //  The port on which the peer is connected
    ///<summary>The declared size of the message (0 for none). The "msize" field is typically not filled out until the MSEVT_MAIL_OK
    /// event at the earliest, and may remain zero (no value) until after the
    /// MSEVT_DATA2 event.</summary>
    msize: INT_32;                        //  The declared size of the message (0 for none)
    ///<summary>The peer's IP address in string form</summary>
    client: PAnsiChar;                    //  The peer's IP address in string form
    ///<summary>Maximum allocated length of "return_path"</summary>
    rplen: INT_32;                        //  Maximum allocated length of "return_path"
    ///<summary>Address specified in MAIL FROM: command. "return-path" will contain the address parameter from a successful SMTP
    ///MAIL FROM command after that command has been processed - event handlers
    /// can refer to it from that point on, but should not usually attempt to
    ///modify it.</summary>
    return_path: PAnsiChar;               //  Address specified in MAIL FROM: command
    ///<summary>Total RCPTs accepted so far in this session</summary>
    rcpts: INT_32;                        //  Total RCPTs accepted so far in this session
    ///<summary>Total RCPTs failed so far in this session</summary>
    bad_rcpts: INT_32;                    //  Total RCPTs failed so far in this session
    ///<summary>Total number of attempted relaying operations</summary>
    relay_attempts: INT_32;               //  Total number of attempted relaying operations
    ///<summary>If "flags  MSEF_DATA_REJECTION", the reason code</summary>
    discard_reason: INT_32;               //  If "flags  MSEF_DATA_REJECTION", the reason code
    ///<summary>The maximum allocated length of "inbuf"</summary>
    inbuflen: INT_32;                     //  The maximum allocated length of "inbuf"
    ///<summary>Event-specific. The "inbuf" field typically contains a pointer to the data on which
    /// MercuryS is basing the notification; in some cases, it may be modifiable,
    /// but not in all - see the documentation associated with the events for
    /// more information on this. If "inbuf" is marked as modifiable for any
    /// given event, the event handler *must* respect the value of "inbuflen",
    /// and *must not* write more than that many bytes of data into the field. It
    /// is also the event handler's obligation to ensure that "inbuf" retains a
    /// valid NUL terminator if it is modified.</summary>
    inbuf: PAnsiChar;                     //  Event-specific
    ///<summary>Event-specific. The "outbuf" field is provided to allow event handlers to provide
    /// feedback or other return data to MercuryS.</summary>
    outbuf: array[0..1023] of AnsiChar;   //  Event-specific
    ///<summary>1.03: Total failed commands this session</summary>
    bad_cmds: INT_32;                    //  1.03: Total failed commands this session
  end; 
  TMSEventBuf = MSEVENTBUF;

//#endif         //  _MSEVENT_H_
implementation

end.

