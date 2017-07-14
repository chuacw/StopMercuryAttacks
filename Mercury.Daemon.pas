unit Mercury.Daemon;
{$MESSAGE WARN 'Most/All int is translated as INT_16. This might not be correct, and if so, should be translated to INT_32'}
{$MESSAGE WARN 'Returns of int can be translated to INT_32, since that return is into CPU registers.'}
// chuacw
{.$WARNINGS OFF}
{$WEAKLINKRTTI ON}

(*

   DAEMON.H - Header for for creating Mercury/32 Daemons
   Mercury Mail Transport System,
   Copyright (c) 1993-2008, David Harris, all rights reserved.

   This file contains all the definitions needed to create a Mercury/32
   Daemon (or "plugin", or "extension", depending on your linguistic
   preferences).

*)
interface
uses Winapi.Windows, Winapi.Messages;
//#ifndef _DAEMON_H_
//#define _DAEMON_H_

(****************************************************************************
  Code setup for compilation using Microsoft Visual C++: we check for
  predefined preprocessor constants that indicate that Visual C++ is in
  use, and if we detect any, we set a preprocessor constant called
  __VISUALC__, which can be queried in Daemon source. We also force the
  structure alignment to single-byte (/Zp1), and include a convenience
  definition for exporting functions from Daemons.
****************************************************************************)

//#ifdef _MSC_VER
//  #define __VISUALC__
//  #define DAEMONEXPORT __declspec(dllexport)
//  #pragma pack(push)
//  #pragma pack(1)
//#else
//  #define DAEMONEXPORT
//#endif

//#ifdef __cplusplus
//extern "C"
//   {
//#endif

type
  UntestedAttribute = class(TCustomAttribute) end;

const
(****************************************************************************
  Basic Mercury data types: this section defines the various Mercury data
  types and structures that are exposed to Daemons and protocol modules
  via this interface.
****************************************************************************)

//  MAXMLINE defines the maximum allowable length of a single line in a
//  mail message. Now, according to RFC2821/2822, no line may exceed 1000
//  characters, but this limit is so commonly ignored that it has no
//  effective meaning any more. In practice, there are enough messages
//  from large systems out there that have lines in the range 2000 to
//  3000 characters long that we have to allow for them.
//
//  Setting MAXMLINE to larger values will consume stack, and may increase
//  paging on the host system, especially if the machine is busy.

  {$EXTERNALSYM MAXMLINE}
  MAXMLINE                            = 8192;

//#ifndef MAXFPATH
  {$EXTERNALSYM MAXFPATH}
  MAXFPATH                            = 128;
//#endif

//#ifndef IDM_COPY
  {$EXTERNALSYM IDM_COPY}
  IDM_COPY                            = 133;
//#endif

  {$EXTERNALSYM MAXUIC}
  MAXUIC                              = 128; 
  {$EXTERNALSYM MAXHOST}
  MAXHOST                             = 128; 

//  Statistics manager constants.

  {$EXTERNALSYM STC_INTEGER}
  STC_INTEGER                         = 0; 
  {$EXTERNALSYM STC_STRING}
  STC_STRING                          = 1; 
  {$EXTERNALSYM STC_DATE}
  STC_DATE                            = 2; 

  {$EXTERNALSYM STF_CUMULATIVE}
  STF_CUMULATIVE                      = 1; 
  {$EXTERNALSYM STF_PEAK}
  STF_PEAK                            = 2; 
  {$EXTERNALSYM STF_UNIQUE}
  STF_UNIQUE                          = 4; 

//  Logging console manager priority constants

  {$EXTERNALSYM LOG_DEBUG}
  LOG_DEBUG                           = 25; 
  {$EXTERNALSYM LOG_INFO}
  LOG_INFO                            = 20; 
  {$EXTERNALSYM LOG_NORMAL}
  LOG_NORMAL                          = 15; 
  {$EXTERNALSYM LOG_SIGNIFICANT}
  LOG_SIGNIFICANT                     = 10;
  {$EXTERNALSYM LOG_URGENT}
  LOG_URGENT                          = 5; 
  {$EXTERNALSYM LOG_NONE}
  LOG_NONE                            = 0; 

//#ifndef INTS_DEFINED
//  #define INTS_DEFINED
////  typedef unsigned char UCHAR;
type

  PUchar = ^TUchar;
  {$EXTERNALSYM UCHAR}
  UCHAR = Byte;
  TUchar = Byte;
////  typedef unsigned short USHORT;

  PUshort = ^TUshort;
  {$EXTERNALSYM USHORT}
  USHORT = Word;
  TUshort = Word;
////  typedef unsigned long ULONG;

  PUlong = ^TUlong;
  {$EXTERNALSYM ULONG}
  ULONG = Longword;
  TUlong = Longword;
////  typedef unsigned short UINT_16;

  PUint16 = ^TUint16;
  {$EXTERNALSYM UINT_16}
  UINT_16 = Word;
  TUint16 = Word;
////  typedef short INT_16;

  PInt16 = ^TInt16;
  {$EXTERNALSYM INT_16}
  INT_16 = Smallint;
  TInt16 = Smallint;
////  typedef unsigned long UINT_32;

  PUint32 = ^TUint32;
  {$EXTERNALSYM UINT_32}
  UINT_32 = Longword;
  TUint32 = Longword;
////  typedef long INT_32;

  PInt32 = ^TInt32;
  {$EXTERNALSYM INT_32}
  INT_32 = Longint;
  TInt32 = Longint;

  // The UINTP and INTP types must equate to integers that are the
  // same size as a native pointer for the host environment.

////  typedef unsigned int UINTP;

  PUintp = ^TUintp;
  {$EXTERNALSYM UINTP}
  UINTP = Cardinal;
  TUintp = Cardinal;
////  typedef int INTP;

  PIntp = ^TIntp;
  {$EXTERNALSYM INTP}
  INTP = Integer;
  TIntp = Integer;
//#endif      //  INTS_DEFINED

const

//  Constants for commands generated by console screens
  {$EXTERNALSYM CMD_CONSOLE_PAUSE}
  CMD_CONSOLE_PAUSE                   = 1024; 
  {$EXTERNALSYM CMD_CONSOLE_POLLNOW}
  CMD_CONSOLE_POLLNOW                 = 1025; 
  {$EXTERNALSYM CMD_CONSOLE_BUTTON1}
  CMD_CONSOLE_BUTTON1                 = 1041; 
  {$EXTERNALSYM CMD_CONSOLE_BUTTON2}
  CMD_CONSOLE_BUTTON2                 = 1042; 
  {$EXTERNALSYM CMD_CONSOLE_BUTTON3}
  CMD_CONSOLE_BUTTON3                 = 1043; 
  {$EXTERNALSYM CMD_CONSOLE_BUTTON4}
  CMD_CONSOLE_BUTTON4                 = 1044; 

    {$EXTERNALSYM WM_XSIZE}
  WM_XSIZE                            = (WM_USER + 1347);
  {$EXTERNALSYM WM_XMOVE}
  WM_XMOVE                            = (WM_USER + 1348);

type

////typedef struct
////   {
////   int dx, dy;
////   RECT oldrect, newrect;
////   WPARAM wParam;
////   int laststate;    //  0 = normal, 1 = maximized, 2 = iconic.
////   } XSIZE;

  PXsize = ^TXsize;
  {$EXTERNALSYM XSIZE}
  XSIZE = packed record
    dx: Integer;
    dy: Integer;
//    oldrect: RECT;
//    newrect: RECT;
    oldrect: TRECT;
    newrect: TRECT;
    wParam: WPARAM;
    laststate: Integer;             //  0 = normal, 1 = maximized, 2 = iconic.
  end;
  TXsize = XSIZE;

// typedef struct
//    {
//    char auto_forward [60];
//    char gw_auto_forward [60];
//    char from_alias [60];      //* 31 May '92: Alternative From: field value */
//    unsigned flags;
//    char security;
//    } PMPROP;

  PPMprop = ^TPMProp;
  {$EXTERNALSYM PMPROP}
  PMPROP = packed record
    auto_forward: array[0..59] of AnsiChar;
    gw_auto_forward: array[0..59] of AnsiChar;
    from_alias: array[0..59] of AnsiChar;  //* 31 May '92: Alternative From: field value */
    flags: Cardinal;
    security: AnsiChar;
  end;
  TPMProp = PMPROP;

const

  {$EXTERNALSYM XSD_DECODE_MIME}
  XSD_DECODE_MIME                     = 1;
  {$EXTERNALSYM XSD_DISABLED}
  XSD_DISABLED                        = 2;
  {$EXTERNALSYM XSD_HEADERSONLY}
  XSD_HEADERSONLY                     = 4;
  {$EXTERNALSYM XSD_LOCALONLY}
  XSD_LOCALONLY                       = 8;
  {$EXTERNALSYM XSD_PREFILTER}
  XSD_PREFILTER                       = 16;
  {$EXTERNALSYM XSD_MODIFIER}
  XSD_MODIFIER                        = 32;

type

// typedef struct
//    {
//    UINT_32 flags;
//    UINT_32 type;
//    char description [50];
//    char cmdline [128];
//    char sentinel [128];
//    char resultfile [128];
//    UINT_32 action;
//    char param [128];
//    } XSCANDEF;

  PXScandef = ^TXScandef;
  {$EXTERNALSYM XSCANDEF}
  XSCANDEF = packed record
    flags: UINT_32;
    &type: UINT_32;
    description: array[0..49] of AnsiChar;
    cmdline: array[0..127] of AnsiChar;
    sentinel: array[0..127] of AnsiChar;
    resultfile: array[0..127] of AnsiChar;
    action: UINT_32;
    param: array[0..127] of AnsiChar;
  end;
  TXScandef = XSCANDEF;


(****************************************************************************
  List Data Structures: Mercury uses two-way doubly-linked lists heavily
  throughout its code, and in a small number of places, these lists are
  exposed to Daemons. Over time, such instances of direct exposure of the
  internal data structures will be phased out and replaced with accessor
  functions or objects, but for now, there may be occasions when it's
  necessary to know the data structures Mercury uses in order to traverse
  an exposed list.
****************************************************************************)

const
//typedef unsigned char BYTE;

  {$EXTERNALSYM LNOMEM}
  LNOMEM                              = 1; //(* Error value for 'not enough core' * div;
  {$EXTERNALSYM LTOOMANY}
  LTOOMANY                            = 2; //(* '    ' ' for ' too many items in list ' */'#13#10'#define LNULLPTR 3         (* ' '    ' when a null pointer is passed * div;
  {$EXTERNALSYM LNOT_SUPPORTED}
  LNOT_SUPPORTED                      = 4; //(* unsupported feature (sorting LVLISTs)* div;
  {$EXTERNALSYM ALLOC}
  ALLOC                               = 1; //(* mnemonics for the ialloc field * div;
  {$EXTERNALSYM NOALLOC}
  NOALLOC                             = 0; //(* '        ' '       ' * div;
  {$EXTERNALSYM LVLIST}
  LVLIST                              = 2; //(* indicates a list using LVNODEs (integral data)* div;

//  #include <_defs.h>

////struct _l_node
////   {
////   unsigned short flags, level;
////   unsigned int number;
////   struct _l_node *next, *prev;
////   void *data;
////   } x;

type

  P_l_node = ^T_l_node;
  {$EXTERNALSYM _l_node}
  _l_node = packed record
    flags: Word;
    level: Word;
    number: Cardinal;
    next: P_l_node;
    prev: P_l_node;
    data: Pointer;
  end;
  T_l_node = _l_node;

////typedef struct _l_node LNODE;

  PLnode = ^TLnode;
  {$EXTERNALSYM LNODE}
  LNODE = _l_node;
  TLnode = _l_node;

////struct _lv_node
////   {
////   unsigned short flags, level;
////   unsigned int number;
////   struct _lv_node *next, *prev;
////   BYTE data [];
////   } _lv_node;

  PLvNode   = ^TLvNode;
  P_lv_node = PLvNode;
  {$EXTERNALSYM _lv_node}
  _lv_node = packed record
    flags: Word;
    level: Word;
    number: Cardinal;
    next: P_lv_node;
    prev: P_lv_node;
    data: array[0..0] of Byte; 
  end; 
  TLvNode = _lv_node; 

  {$EXTERNALSYM LVNODE}
  LVNODE = _lv_node;

////typedef struct LIST
////   {
////   LNODE *top, *end;          //(* pointers to start/end of list */
////   int icount;                //(* number of items in list */
////   unsigned isize;            //(* size of *data in LNODE */
////   int ilimit;                //(* maximum size of list - no limit if 0 */
////   int ialloc;                //(* whether or not to allocate space for items */
////   unsigned int last_acc;     //(* Last data accessed using get_list_data */
////   LNODE *last_data;          //(* "   "   "   "   "   "   "   "   "    " */
////   } LIST;

  PList = ^TList;
  {$EXTERNALSYM LIST}
  LIST = packed record
    top: PLNODE;
    &end: PLNODE;                     //(* pointers to start/end of list */
    icount: Integer;                 //(* number of items in list */
    isize: Cardinal;                 //(* size of *data in LNODE */
    ilimit: Integer;                 //(* maximum size of list - no limit if 0 */
    ialloc: Integer;                 //(* whether or not to allocate space for items */
    last_acc: Cardinal;              //(* Last data accessed using get_list_data */
    last_data: PLNODE;              //(* "   "   "   "   "   "   "   "   "    " */
  end;
  TList = LIST; 


(****************************************************************************
  Folder Management routines and structures: Mercury's folder management
  code derives directly from Pegasus Mail, and as such carries around a
  large number of exposed data structures. While this interface is quite
  robust (MercuryI uses it exclusively), it requires considerable internal
  knowledge to use correctly, and should be avoided if at all possible.

  In time, this interface will be completely deprecated and replaced with
  an object-based version.
****************************************************************************)
const
//  Messages that can be sent to folders, or by folders
  {$EXTERNALSYM FPM_GETCOMMAND}
  FPM_GETCOMMAND                      = (WM_USER + 1);
  {$EXTERNALSYM FPM_DOCOMMAND}
  FPM_DOCOMMAND                       = (WM_USER + 2); 
  {$EXTERNALSYM FPM_FOLINFO}
  FPM_FOLINFO                         = (WM_USER + 3); 
  {$EXTERNALSYM FPM_GETPATH}
  FPM_GETPATH                         = (WM_USER + 4); 
  {$EXTERNALSYM FPM_REPLACEMESSAGE}
  FPM_REPLACEMESSAGE                  = (WM_USER + 5); 
  {$EXTERNALSYM FPM_MAKE_TRAY}
  FPM_MAKE_TRAY                       = (WM_USER + 6);  //  parm1 = FPLC_TRAYDATA *
  {$EXTERNALSYM FPM_DELETE_TRAY}
  FPM_DELETE_TRAY                     = (WM_USER + 7);  //  parm1 = FPLC_TRAYDATA *
  {$EXTERNALSYM FPM_RENAME_TRAY}
  FPM_RENAME_TRAY                     = (WM_USER + 8);  //  parm1 = FPLC_TRAYDATA *
  {$EXTERNALSYM FPM_MAKE_FOLDER}
  FPM_MAKE_FOLDER                     = (WM_USER + 9);  //  parm1 = FPLC_TRAYDATA *
  {$EXTERNALSYM FPM_GET_FTYPE}
  FPM_GET_FTYPE                       = (WM_USER + 10);  //  parm1 = item, parm2 = buffer
  {$EXTERNALSYM FPM_DISCARD_TRAY}
  FPM_DISCARD_TRAY                    = (WM_USER + 11);  //  parm1 = FPLC_TRAYDATA *
  {$EXTERNALSYM FPM_CAN_DISMOUNT}
  FPM_CAN_DISMOUNT                    = (WM_USER + 12);  //  parm1 = 0, parm2 = 0
  {$EXTERNALSYM FPM_DISMOUNT}
  FPM_DISMOUNT                        = (WM_USER + 13);  //  parm1 = mbx_id, parm2 = 0
  {$EXTERNALSYM FPM_SUPPRESS_TRAYS}
  FPM_SUPPRESS_TRAYS                  = (WM_USER + 14);  //  parm1 = mbx_id, parm2 = 0
  {$EXTERNALSYM FPM_GET_STATUSSTEP}
  FPM_GET_STATUSSTEP                  = (WM_USER + 15); 
  {$EXTERNALSYM FPM_RESYNCHRONIZE}
  FPM_RESYNCHRONIZE                   = (WM_USER + 16);  //  parm1 = FOLDER *.
  {$EXTERNALSYM FPM_COUNT}
  FPM_COUNT                           = (WM_USER + 17);  //  parm1 = FOLDER *.

    {$EXTERNALSYM FPM_GETFNAME}
  FPM_GETFNAME                        = (WM_USER + 256);  // parm1 = len, parm2 = char *
  {$EXTERNALSYM FPM_GETHOMEBOX}
  FPM_GETHOMEBOX                      = (WM_USER + 257);  // parm1 = len, parm2 = char *

  {$EXTERNALSYM FPC_GETDATA}
  FPC_GETDATA                         = (WM_USER + 1024); 
  {$EXTERNALSYM FPC_GETMBXDATA}
  FPC_GETMBXDATA                      = (WM_USER + 1025); 


//  Field lengths
  {$EXTERNALSYM MAXVNAME}
  MAXVNAME                            = 50; 
  {$EXTERNALSYM MAXID}
  MAXID                               = 34; 


//  Flags used by the hierarchy management code in FOLMAN.C
  {$EXTERNALSYM FTF_IS_OPEN}
  FTF_IS_OPEN                         = 1; 
  {$EXTERNALSYM FTF_CONTAINS_NEWMAIL}
  FTF_CONTAINS_NEWMAIL                = 2; 
  {$EXTERNALSYM FTF_IS_TRANSIENT}
  FTF_IS_TRANSIENT                    = 4; 
  {$EXTERNALSYM FTF_DELETE_ME}
  FTF_DELETE_ME                       = 8; 
  {$EXTERNALSYM FTF_TRAYFOLDER}
  FTF_TRAYFOLDER                      = 16; 
  {$EXTERNALSYM FTF_DELETED_MESSAGES}
  FTF_DELETED_MESSAGES                = 256;


//  Flags for the "flags" field of an FPLDATA structure
  {$EXTERNALSYM FPL_INTERNAL}
  FPL_INTERNAL                        = 1;  //  Not a DLL - don't get procedure addresses


//  27 Jan '00: (Mercury only) values for the "flags" field of an
//  FCD connection control structure.

  {$EXTERNALSYM FCD_SAVE_DELETED}
  FCD_SAVE_DELETED                    = 1; 


//  Flags for the "flags" field of a FOLDER structure
  {$EXTERNALSYM FF_IS_OPEN}
  FF_IS_OPEN                          = 1; 
  {$EXTERNALSYM FF_IS_TRANSIENT}
  FF_IS_TRANSIENT                     = 4; 
  {$EXTERNALSYM FF_NO_CREATE}
  FF_NO_CREATE                        = 32; 
  {$EXTERNALSYM FF_HIDDEN}
  FF_HIDDEN                           = 64; 
  {$EXTERNALSYM FF_IS_HIERARCHICAL}
  FF_IS_HIERARCHICAL                  = 128;  //  Folder can contain other folders
  {$EXTERNALSYM FF_RESYNCHRONIZE}
  FF_RESYNCHRONIZE                    = 256;  //  Folder should be periodically resynched
  {$EXTERNALSYM FF_IS_FAKE}
  FF_IS_FAKE                          = $10000; 


//  Flags for the "flags" parameter to "fm_get_folder"
  {$EXTERNALSYM FF_ALL_FOLDERS}
  FF_ALL_FOLDERS                      = 1; 
  {$EXTERNALSYM FF_ALL_OPEN_FOLDERS}
  FF_ALL_OPEN_FOLDERS                 = 2; 


//  Flags for "fm_open_message" and "fm_associate_file"
  {$EXTERNALSYM FF_RAW}
  FF_RAW                              = 1;  //  No decryption
  {$EXTERNALSYM FF_PARSING_HEADERS}
  FF_PARSING_HEADERS                  = 2;  //  Only the headers are required
  {$EXTERNALSYM FF_PARSING_FULL}
  FF_PARSING_FULL                     = 4;  //  Headers + probe depth are required
  {$EXTERNALSYM FF_NO_LINE_ENDINGS}
  FF_NO_LINE_ENDINGS                  = 8;  //  Tells "f_gets" to strip line terminators
  {$EXTERNALSYM FPL_CREATE}
  FPL_CREATE                          = 16;  //  WinPMail wants to write a message
  {$EXTERNALSYM FF_TEMPORARY}
  FF_TEMPORARY                        = 32;  //  Delete when closing
  {$EXTERNALSYM FF_AUTODISSOCIATE}
  FF_AUTODISSOCIATE                   = 64; 
  {$EXTERNALSYM FF_EXTENDEDERRORS}
  FF_EXTENDEDERRORS                   = 128; 

  {$EXTERNALSYM FPL_WHOLE_MESSAGE}
  FPL_WHOLE_MESSAGE                   = -1;


//  Flags for "fm_extract_*_message"
  {$EXTERNALSYM FFX_APPEND}
  FFX_APPEND                          = 1;  //  Append to the file if it exists
  {$EXTERNALSYM FFX_NO_HEADERS}
  FFX_NO_HEADERS                      = 2;  //  Omit the headers when writing
  {$EXTERNALSYM FFX_TIDY_HEADERS}
  FFX_TIDY_HEADERS                    = 4;  //  Write only "significant" headers
  {$EXTERNALSYM FFX_NOT_OPEN}
  FFX_NOT_OPEN                        = 8;  //  The job is not open on entry
  {$EXTERNALSYM FFX_NO_BODY}
  FFX_NO_BODY                         = 16;  //  Extract the message headers only
  {$EXTERNALSYM FFX_PARSING}
  FFX_PARSING                         = 32;  //  Extract a parseable portion of the message


//  Flags for "fm_delete_message"
  {$EXTERNALSYM FF_DELETE_ATTACHMENTS}
  FF_DELETE_ATTACHMENTS               = 1;  //  Delete message attachments as well
  {$EXTERNALSYM FF_DEEPSIXIT}
  FF_DEEPSIXIT                        = 2;  //  Bypass deletion preservation options
  {$EXTERNALSYM FF_SAVE_ANNOTATIONS}
  FF_SAVE_ANNOTATIONS                 = 4;  //  Don't delete annotations (for moving)


//  Flags for "fm_open_folder"
  {$EXTERNALSYM FF_CAN_CREATE}
  FF_CAN_CREATE                       = 1;  //  OK to create folder if it doesn't exist
  {$EXTERNALSYM FF_NO_LIST}
  FF_NO_LIST                          = 2;  //  Don't build a list of the folder contents
  {$EXTERNALSYM FF_UNIQUE}
  FF_UNIQUE                           = 4;  //  Don't allow multiple open instances


//  Flags for "fm_copy_file_into_folder"
  {$EXTERNALSYM FF_NO_PARSE}
  FF_NO_PARSE                         = 1; 


//  Flags for "fm_mount_mailbox"
  {$EXTERNALSYM FF_NO_SCAN}
  FF_NO_SCAN                          = 1;  //  Don't poll this mailbox for folders
  {$EXTERNALSYM FF_NO_INIT}
  FF_NO_INIT                          = 2;  //  Don't reinit the plugins for this mailbox
  {$EXTERNALSYM FF_DUMMY_MAILBOX}
  FF_DUMMY_MAILBOX                    = 3;  //  A synonym for "FF_NO_SCAN | FF_NO_INIT"
  {$EXTERNALSYM FF_RATIONALIZED}
  FF_RATIONALIZED                     = 4;  //  Set by hierarchy manager
  {$EXTERNALSYM FF_TRANSIENT_MAILBOX}
  FF_TRANSIENT_MAILBOX                = 8;  //  Mailbox should not be stored


//  Possible return flags for fm_get_message_caps
  {$EXTERNALSYM FF_CAN_EDIT1}
  FF_CAN_EDIT1                        = 4;  //  Supports editing message flags
  {$EXTERNALSYM FF_CAN_EDIT2}
  FF_CAN_EDIT2                        = 8;  //  Supports editing from/subject fields
  {$EXTERNALSYM FF_CAN_EDIT3}
  FF_CAN_EDIT3                        = 16;  //  Supports wholesale message changes



//  The FOLDER structure is used internally to represent a
//  folder (i.e, a container for IMESSAGE structures).

////typedef struct
////   {
////   //  ---- Publicly-accessible fields --------------------
////   char vname [MAXVNAME];     //  Folder's logical name
////   char unique_id [MAXID];    //  Unique identifier for this folder
////   UINT_32 flags;             //  Folder state and characteristic flags
////   INT_32 unread;             //  Number of unread messages in folder
////   INT_32 total;              //  Total number of messages in folder
////   LIST *folder_list;         //  The folder's message list
////   LNODE *nextnode;           //  Next node in message list after deletion
////   UINT_32 tle_handle;        //  Telltale Manger handle for this folder
////
////   //  ---- Private internal fields -----------------------
////   char reserved [60];        //  Private internal data
////   } FOLDER;
type
  PFolder = ^TFolder;
  {$EXTERNALSYM FOLDER}
  [Untested]
  FOLDER = packed record
                                                  //  ---- Publicly-accessible fields --------------------
    vname: array[0..MAXVNAME - 1] of AnsiChar;    //  Folder's logical name
    unique_id: array[0..MAXID - 1] of AnsiChar;   //  Unique identifier for this folder
    flags: UINT_32;                               //  Folder state and characteristic flags
    unread: INT_32;                               //  Number of unread messages in folder
    total: INT_32;                                //  Total number of messages in folder
    folder_list: PLIST;                           //  The folder's message list
    nextnode: PLNODE;                             //  Next node in message list after deletion
    tle_handle: UINT_32;                          //  Telltale Manger handle for this folder
                                                  //  ---- Private internal fields -----------------------
    reserved: array[0..59] of AnsiChar;          //  Private internal data
  end;
  TFolder = FOLDER;


//  The IMESSAGE structure is used internally to represent messages
//  and pseudo-messages.

////typedef struct
////   {
////   INT_16 dsize;               //  The size of this data structure
////   INT_16 mtype;               //  User-defined message type field
////   UINT_32 flags;              //  First bank of message-related flags
////   UINT_32 flags2;             //  Second bank of message-related flags
////   char fname [14];            //  Recommended filename for message
////   char from [42];             //  The sender of the message
////   char subject [50];          //  Can you guess what this is?
////   UCHAR cdate [8];            //  Timezone-corrected date from message
////   UCHAR date [8];             //  Raw RFC822 time and date for message
////   UINT_32 fsize;              //  Raw size of this message
////   UINT_16 colour;             //  Display colour for this entry
////   UINT_16 charset;            //  Character set for message
////   char unique_id [34];        //  Unique ID for the message
////   FOLDER *folder;             //  The folder containing the message
////   UINT_32 imap_uid;           //  For use by the MercuryI IMAP module
////   UINT_32 fdata1;             //  Private data for foldering plugin
////   UINT_32 fdata2;             //  Private data for foldering plugin
////   } IMESSAGE;                 //  ** Total size: 192 bytes.

  PIMessage = ^TIMessage;
  {$EXTERNALSYM IMESSAGE}
  [Untested]
  IMESSAGE = packed record
    dsize: INT_16;                         //  The size of this data structure
    mtype: INT_16;                         //  User-defined message type field
    flags: UINT_32;                        //  First bank of message-related flags
    flags2: UINT_32;                       //  Second bank of message-related flags
    fname: array[0..13] of AnsiChar;       //  Recommended filename for message
    from: array[0..41] of AnsiChar;        //  The sender of the message
    subject: array[0..49] of AnsiChar;     //  Can you guess what this is?
    cdate: array[0..7] of UCHAR;           //  Timezone-corrected date from message
    date: array[0..7] of UCHAR;            //  Raw RFC822 time and date for message
    fsize: UINT_32;                        //  Raw size of this message
    colour: UINT_16;                       //  Display colour for this entry
    charset: UINT_16;                      //  Character set for message
    unique_id: array[0..33] of AnsiChar;   //  Unique ID for the message
    folder: PFOLDER;                       //  The folder containing the message
    imap_uid: UINT_32;                     //  For use by the MercuryI IMAP module
    fdata1: UINT_32;                       //  Private data for foldering plugin
    fdata2: UINT_32;                      //  Private data for foldering plugin
  end;
  TIMessage = IMESSAGE;
  //  ** Total size: 192 bytes.

//  Explanation of fields:
//  "dsize"      The allocated size of this data structure
//  "mtype"      The user can define message types that can be used for sorting
//  "flags"      Can contain any of the flag values shown in Group 1 below
//  "flags2"     Can contain any of the flag values shown in Group 2 below
//  "fname"      Recommended filename for any storage to do with the message
//  "from"       Display version of sender's address
//  "subject"    Display version of message subject
//  "date"       The date as shown in the message's RFC822 "Date:" field
//  "cdate"      The date the message arrived at the local system.
//             - See below for more on the date format
//  "fsize"      Raw size of the message, including headers and formatting
//               Note - no allowance is made for CR/LF conversions.
//  "colour"     Index into colour table for message display colour
//  "charset"    Index into character set table for message charset format
//  "unique_id"  Guaranteed unique persistent global identifier for this message
//  "folder"     The folder in which this message is currently stored.
//  "idata"      Used internally - client routines must not examine or change
//  "fdata1"     For the use of the owning folder service provider module
//  "fdata2"     "   "
//
//  The "folder", "fdata?" and "idata" fields should be considered volatile
//  between sessions (foldering modules need not store them on disk); all other
//  values should be constant between sessions, especially the unique ID field,
//  which is required to last for the duration of the message's valid life. The
//  field has been specifically designed to be large enough to hold an MD5
//  digest string.
//
//  Only the WinPMail core message store functions and foldering plugins should
//  alter fields in this structure - all others should treat it as read-only.
//  The exception to this rule is the "flags" and "flags2" fields, which may
//  on occasion be changed and saved under client control.
//
//  Date format: dates in IMESSAGEs use the NetWare 7-byte date format plus an
//  extra byte containing the offset in half-hour units from GMT. The date is
//  always pre-corrected to GMT by WinPMail. Note that byte 0 (the year) is
//  always the actual year - 1900, so the year 2000 is represented by 100.
//  The NetWare date format is as shown:
//
//    Byte 0  - Year - 1900 (i.e, 2005 = 105)
//    Byte 1  - Month (ie, January == 1)
//    Byte 2  - Day (1 .. 31)
//    Byte 3  - Hour (0 - 24)
//    Byte 4  - Minute (0 - 59)
//    Byte 5  - Second (0 - 60)
//    Byte 6  - Day of week (Sunday == 0)   ("255" == "not calculated")

const

//
//  Group 1 flag values - these can be used in an IMESSAGE "flags" field.
//
  {$EXTERNALSYM FILE_MAILED}
  FILE_MAILED                         = 1;  // The message contains a mailed file
  {$EXTERNALSYM UUENCODED}
  UUENCODED                           = 2;  // The message contains uuencoded data
  {$EXTERNALSYM FILE_ATTACHED}
  FILE_ATTACHED                       = $800003;  // Use this as an attachment mask.
  {$EXTERNALSYM ENCRYPTED}
  ENCRYPTED                           = 4;  // The message is encrypted
  {$EXTERNALSYM EXPIRED}
  EXPIRED                             = 16;  // The message is past its expiry date
  {$EXTERNALSYM FILE_ASCII}
  FILE_ASCII                          = 32;  // Flag in attachment to indicate ASCII file
  {$EXTERNALSYM HAS_BEEN_READ}
  HAS_BEEN_READ                       = 128;  // Hey, what do you know! It's been read!
  {$EXTERNALSYM ALTERNATIVE}
  ALTERNATIVE                         = $100;  // The message is Multipart/Alternative type
  {$EXTERNALSYM IS_HTML}
  IS_HTML                             = $200;  // The message is Text/HTML type
  {$EXTERNALSYM IS_CIRCULAR}
  IS_CIRCULAR                         = $400;  // The message is being circulated
  {$EXTERNALSYM IS_NESTED}
  IS_NESTED                           = $800;  // Message contains another message
  {$EXTERNALSYM IS_DRAFT}
  IS_DRAFT                            = $1000;  // The message may be a reloadable draft
  {$EXTERNALSYM CONFIRMATION}
  CONFIRMATION                        = $2000;  // Sender wants confirmation of reading
  {$EXTERNALSYM CC_CHECKED}
  CC_CHECKED                          = $4000;  // Message has been content-checked
  {$EXTERNALSYM FORWARD}
  FORWARD                             = $8000;  // The message is being forwarded
  {$EXTERNALSYM IS_RTF}
  IS_RTF                              = $10000;  // Message contains MS-RTF data
  {$EXTERNALSYM COPYSELF}
  COPYSELF                            = $20000;  // The message is a copy to self
  {$EXTERNALSYM DELETED}
  DELETED                             = $40000;  // The message has been deleted.
  {$EXTERNALSYM MIME}
  MIME                                = $80000;  // The message is a MIME transmission
  {$EXTERNALSYM REPLIED}
  REPLIED                             = $100000;  // The message has been replied to.
  {$EXTERNALSYM FORWARDED}
  FORWARDED                           = $200000;  // The message has been forwarded.
  {$EXTERNALSYM URGENT}
  URGENT                              = $400000;  // The message is urgent/high priority.
  {$EXTERNALSYM BINHEX}
  BINHEX                              = $800000;  // The message is a BinHex file
  {$EXTERNALSYM IS_MHS}
  IS_MHS                              = $1000000;  // The message originates from MHS
  {$EXTERNALSYM IS_SMTP}
  IS_SMTP                             = $2000000;  // The message originated via SMTP
  {$EXTERNALSYM IS_ANNOTATED}
  IS_ANNOTATED                        = $4000000;  // The message has an annotation
  {$EXTERNALSYM ENCLOSURE}
  ENCLOSURE                           = $8000000;  // The message has an enclosure
  {$EXTERNALSYM HIGHLIGHTED}
  HIGHLIGHTED                         = $10000000;  // The message has transient significance
  {$EXTERNALSYM MIME_MULTI}
  MIME_MULTI                          = $20000000;  // The message is in MIME Multipart format
  {$EXTERNALSYM TEXT_ENRICHED}
  TEXT_ENRICHED                       = $40000000;  // The message is in "text/enriched" format
  {$EXTERNALSYM READ_ONLY}
  READ_ONLY                           = $80000000;  // The message may not be deleted

//
//  Group 2 flag values - these can be used in an IMESSAGE "flags2" field
//

  {$EXTERNALSYM IS_NEWMAIL}
  IS_NEWMAIL                          = 1;  // The message is in the new mail folder
  {$EXTERNALSYM IS_NOTICE}
  IS_NOTICE                           = 2;  // The message comes from a noticeboard
  {$EXTERNALSYM IS_SIGNIFICANT}
  IS_SIGNIFICANT                      = 4;  // Message is temporarily "significant"
  {$EXTERNALSYM PENDING_DELETE}
  PENDING_DELETE                      = 8;  // Message is marked for deletion

type
//  ATTACHMENT structures are used to represent the attachments to
//  non-MIME mail messages.

//enum {UNKNOWN, MAC, DOS};     (* Attachment origins */

////typedef struct ATTACHMENT
////   {
////   char fname [256];          //(* Definition used internally to represent *)
////   char original_name [128];  //(* attachments to messages, both incoming and *)
////   char ofname [128];         //(* outgoing. *)
////   long fsize;
////   long creator;
////   long ftype;
////   INT_16 finder_flags;
////   unsigned long flags;
////   INT_16 encoding;
////   char origin;
////   char attachment_type [32];
////   long fpos;
////   char tmp_encoding;
////   char description [64];
////   } ATTACHMENT;

  PAttachment = ^TAttachment;
  {$EXTERNALSYM ATTACHMENT}
  [Untested]
  ATTACHMENT = packed record
    fname: array[0..255] of AnsiChar;           //(* Definition used internally to represent *)
    original_name: array[0..127] of AnsiChar;   //(* attachments to messages, both incoming and *)
    ofname: array[0..127] of AnsiChar;          //(* outgoing. *)
    fsize: Longint;
    creator: Longint;
    ftype: Longint;
    finder_flags: INT_16;
    flags: Longword;
    encoding: INT_16;
    origin: AnsiChar;
    attachment_type: array[0..31] of AnsiChar;
    fpos: Longint;
    tmp_encoding: AnsiChar;
    description: array[0..63] of AnsiChar;
  end;
  TAttachment = ATTACHMENT; 

////typedef struct
////   {
////   char *name;
////   int ntype;
////   char *unique_id;
////   char *parent_id;
////   FOLDER *folder;
////   } FMM_ENTRY;

  PFmmEntry = ^TFmmEntry; 
  {$EXTERNALSYM FMM_ENTRY} 
  [Untested]
  FMM_ENTRY = packed record
    name: PAnsiChar;
    ntype: Integer;
    unique_id: PAnsiChar;
    parent_id: PAnsiChar; 
    folder: PFOLDER; 
  end;
  TFmmEntry = FMM_ENTRY; 


(****************************************************************************
  MIME Parser structures: Mercury incorporates a complete linear MIME
  parser which is made available to Daemons. As with the comments about
  the list data structures above, the MIME parser will eventually be
  replaced with an object, but for now, these definitions are required
  to use it.
****************************************************************************)

{$MESSAGE WARN 'Enums need conversion???'}

//enum     //  Content dispositions
//   {
//   MD_ATTACHMENT, MD_INLINE
//   };
//
//enum     // The primary types
//   {
//   MP_TEXT, MP_MULTIPART, MP_MESSAGE, MP_APPLICATION,
//   MP_IMAGE, MP_VIDEO, MP_AUDIO, MP_UNKNOWN
//   };
//
//enum     // TEXT subtypes
//   {
//   MPT_PLAIN, MPT_RICHTEXT, MPT_HTML, MPT_RTF, MPT_UNKNOWN
//   };
//
//enum     // MULTIPART subtypes
//   {
//   MPP_MIXED, MPP_ALTERNATIVE, MPP_DIGEST,
//   MPP_PARALLEL, MPP_UNKNOWN
//   };
//
//enum     // MESSAGE subtypes
//   {
//   MPM_RFC822, MPM_PARTIAL, MPM_EXTERNAL_BODY, MPM_DISPNOT, MPM_UNKOWN
//   };
//
//enum     // APPLICATION subtypes
//   {
//   MPA_OCTET_STREAM, MPA_POSTSCRIPT, MPA_ODA, MPA_BINHEX, MPA_UNKNOWN
//   };
//
//enum     // IMAGE subtypes
//   {
//   MPI_GIF, MPI_JPEG, MPI_UNKNOWN
//   };
//
//enum     // VIDEO subtypes
//   {
//   MPV_MPEG, MPV_UNKNOWN
//   };
//
//enum     // AUDIO subtypes
//   {
//   MPU_BASIC, MPU_UNKNOWN
//   };
//
//enum     // MIME transfer-encodings
//   {
//   //  Note that ME_BINHEX and ME_UUENCODE are handled as special
//   //  cases and as such must always appear after ME_UNKNOWN.
//   ME_7BIT, ME_8BIT, ME_QUOTED_PRINTABLE, ME_BASE64, ME_UNKNOWN,
//   ME_BINHEX, ME_UUENCODE
//   };


////typedef struct
////   {
////   char charset [20];
////   char *table;
////   } MPT;

  PMpt = ^TMpt;
  {$EXTERNALSYM MPT}
  [Untested]
  MPT = packed record
    charset: array[0..19] of AnsiChar;
    table: PAnsiChar;
  end;
  TMpt = MPT;

////typedef struct
////   {
////   char boundary [71];
////   LIST partlist;
////   } MPP;

  PMpp = ^TMpp;
  {$EXTERNALSYM MPP}
  [Untested]
  MPP = packed record
    boundary: array[0..70] of AnsiChar;
    partlist: LIST;
  end;
  TMpp = MPP;

////typedef struct
////   {
////   char fname [96];
////   char type [20];
////   } MPA;

  PMpa = ^TMpa;
  {$EXTERNALSYM MPA}
  [Untested]
  MPA = packed record
    fname: array[0..95] of AnsiChar;
    &type: array[0..19] of AnsiChar;
  end;
  TMpa = MPA;

////typedef struct
////   {
////   int primary, secondary, encoding, disposition;
////   char p_string [20], s_string [20];
////   char description [48];
////   char encryptor [16];    //  For encrypted attachments, the encryptor
////   int encryptor_flags;
////   int section;
////   char fname [96];
////   union
////      {
////      MPT mpt;
////      MPP mpp;
////      MPA mpa;
////      IMESSAGE mpm;
////      } d;
////   } IMIME;

  PImime = ^TImime;
  {$EXTERNALSYM IMIME}
  [Untested]
  IMIME = packed record
    primary: Integer;
    secondary: Integer;
    encoding: Integer;
    disposition: Integer;
    p_string: array[0..19] of AnsiChar;
    s_string: array[0..19] of AnsiChar;
    description: array[0..47] of AnsiChar;
    encryptor: array[0..15] of AnsiChar;  //  For encrypted attachments, the encryptor
    encryptor_flags: Integer;
    section: Integer;
    fname: array[0..95] of AnsiChar;
    d: record
      mpt: MPT;
      mpp: MPP;
      mpa: MPA;
      mpm: IMESSAGE;
    end;
  end; 
  TImime = IMIME; 

const

(****************************************************************************
  Queue and Job management functions and structures: Mercury's mail queue
  manager is extremely robust and is made completely available to Daemons
  and protocol modules via these functions and structures. Note that the
  queue manager is completely serialized, and can be used safely from
  multi-threaded code.
****************************************************************************)

//  Rewind flags - passed to ji_rewind_job

  {$EXTERNALSYM JR_CONTROL}
  JR_CONTROL                          = 1;
  {$EXTERNALSYM JR_DATA}
  JR_DATA                             = 2;

//  Diagnostic flags - passed to ji_set/get_diagnostics

  {$EXTERNALSYM JD_ELEMENT}
  JD_ELEMENT                          = 1; 
  {$EXTERNALSYM JD_JOB}
  JD_JOB                              = 2; 

//  Job state flags: these are the possible bits returned by
//  ji_get_job_state; client routines should only rely on the
//  meaning of the J_LOCKED, J_OPEN and J_CREATED bits.

  {$EXTERNALSYM J_CREATED}
  J_CREATED                           = 1;  //  Set if the job is newly-created.
  {$EXTERNALSYM J_REQUEUED}
  J_REQUEUED                          = 2;  //  Set if the job has been requeued already
  {$EXTERNALSYM J_DELETED}
  J_DELETED                           = 4;  //  Set if the job has been deleted
  {$EXTERNALSYM J_DISPOSED}
  J_DISPOSED                          = 256;  //  Set if the job has been disposed
  {$EXTERNALSYM J_LOCKED}
  J_LOCKED                            = $200;  //  Set if the job is currently locked
  {$EXTERNALSYM J_OPEN}
  J_OPEN                              = $400;  //  Job is currently open

//  Job flags - stored in the "jobflags" field of a JOBINFO
//  The LS 4 bits of the flag word are a mask for a highlight
//  colour that can be specified when the message is written
//  to a local user.

  {$EXTERNALSYM JF_NOFILTER}
  JF_NOFILTER                         = $100;  //  Do not apply filtering to this job
  {$EXTERNALSYM JF_EXPIRE}
  JF_EXPIRE                           = $200;  //  Expire the message when writing it
  {$EXTERNALSYM JF_SCANNED}
  JF_SCANNED                          = $400;  //  The message has been externally scanned
  {$EXTERNALSYM JF_LOCAL}
  JF_LOCAL                            = $800;  //  The message was submitted locally
  {$EXTERNALSYM JF_VERPJOB}
  JF_VERPJOB                          = $1000;  //  Process this message as a VERP probe
  {$EXTERNALSYM JF_WARN1}
  JF_WARN1                            = $2000;  //  An initial delay warning has been sent
  {$EXTERNALSYM JF_WARN2}
  JF_WARN2                            = $4000;  //  A second delay warning has been sent
  {$EXTERNALSYM JF_WARN3}
  JF_WARN3                            = $8000;  //  A third delay warning has been sent
  {$EXTERNALSYM JF_RES1}
  JF_RES1                             = $10000;  //  Reserved
  {$EXTERNALSYM JF_RES2}
  JF_RES2                             = $20000;  //  Reserved
  {$EXTERNALSYM JF_RES3}
  JF_RES3                             = $40000;  //  Reserved

type

////typedef struct
////   {
////   int structlen;
////   char jobstatus;
////   long jobflags;
////   char status;
////   char *from;
////   char *to;
////   long dsize;
////   long rsize;
////   int total_rcpts;
////   int total_failures;
////   int total_retries;
////   char ip1 [16];
////   char ip2 [16];
////   char ip3 [16];
////   char ip4 [16];
////   char jobid [20];
////   } JOBINFO;

  PJobinfo = ^TJobinfo;
  {$EXTERNALSYM JOBINFO}
  [Untested]
  JOBINFO = packed record
    structlen: Integer;
    jobstatus: AnsiChar;
    jobflags: Longint;
    status: AnsiChar;
    from: PAnsiChar;
    &to: PAnsiChar;
    dsize: Longint;
    rsize: Longint;
    total_rcpts: Integer;
    total_failures: Integer;
    total_retries: Integer;
    ip1: array[0..15] of AnsiChar;
    ip2: array[0..15] of AnsiChar;
    ip3: array[0..15] of AnsiChar;
    ip4: array[0..15] of AnsiChar;
    jobid: array[0..19] of AnsiChar;
  end;
  TJobinfo = JOBINFO;

////typedef struct
////   {
////   int ssize;
////   long total_gjobs;
////   long total_ojobs;
////   long ready_gjobs;
////   long ready_ojobs;
////   long pending_gjobs;
////   long pending_ojobs;
////   long finished_gjobs;
////   long finished_ojobs;
////   } JQINFO;

  PJqinfo = ^TJqinfo;
  {$EXTERNALSYM JQINFO}
  [Untested]
  JQINFO = packed record
    ssize: Integer;
    total_gjobs: Longint;
    total_ojobs: Longint;
    ready_gjobs: Longint;
    ready_ojobs: Longint;
    pending_gjobs: Longint;
    pending_ojobs: Longint;
    finished_gjobs: Longint;
    finished_ojobs: Longint;
  end;
  TJqinfo = JQINFO;

{$MESSAGE WARN 'Enums need conversion???'}
//enum                 //  Job types, for ji_scan_* and ji_create_job
//   {
//   JT_GENERAL,       //  Local and newly-submitted mail
//   JT_OUTGOING,      //  Only mail destined for the outside world
//   JT_ANY,           //  Any type of job
//   JT_USER1 = 256,   //  Privately-defined job types.
//   JT_USER2,
//   JT_USER3,
//   JT_USER4,
//   JT_USER5
//   };
//
//enum                 //  "mode" values for ji_set_element_status
//   {
//   JS_COMPLETED,     //  "date" is ignored
//   JS_FAILED,        //  "date" is ignored
//   JS_RETRY,         //  "date" is used for requeuing if non-NULL
//   JS_PENDING,       //  "date" is ignored
//   JS_TEMP_FAIL      //  "date" is ignored
//   };
//
//enum                 //  "type" values for ji_get_next_element
//   {
//   JE_ANY,           //  Any type of element is OK
//   JE_READY,         //  Only return elements ready to be sent
//   JE_FAILED,        //  Only return elements marked as failed
//   JE_COMPLETED,     //  Only return elements marked as completed
//   JE_PENDING,       //  Only return elements marked as "pending"
//   JE_TEMP_FAIL,     //  Only return elements marked as temporarily failed
//   JE_NEW            //  Only return ready items not previously processed
//   };

const

(****************************************************************************
  Mailing List data structures: without wanting to sound like a broken
  record, these data structures are now deprecated and will be replaced
  in time with object-based equivalents. While the mechanism defined here
  is robust, as with folders, it requires considerable familiarity with
  the internal workings of the Mercury code to use safely. You should
  avoid using these routines if at all possible, waiting instead for the
  object-based version to become available.
****************************************************************************)

  {$EXTERNALSYM DLPWD_MODERATOR}
  DLPWD_MODERATOR                     = 0;
  {$EXTERNALSYM DLPWD_POSTING}
  DLPWD_POSTING                       = 1;
  {$EXTERNALSYM DLPWD_SUBSCRIBE}
  DLPWD_SUBSCRIBE                     = 2;

    {$EXTERNALSYM VERP_MODE_CONVENTIONAL}
  VERP_MODE_CONVENTIONAL              = 0;
  {$EXTERNALSYM VERP_MODE_VERP}
  VERP_MODE_VERP                      = 1; 
  {$EXTERNALSYM VERP_MODE_HYBRID}
  VERP_MODE_HYBRID                    = 2; 

  {$EXTERNALSYM VERP_ERR_DELETE}
  VERP_ERR_DELETE                     = 1; 
  {$EXTERNALSYM VERP_ERR_MONTHLY}
  VERP_ERR_MONTHLY                    = 2; 
  {$EXTERNALSYM VERP_ERR_WEEKLY}
  VERP_ERR_WEEKLY                     = 4;
  {$EXTERNALSYM VERP_SUMMARY}
  VERP_SUMMARY                        = 256;
  {$EXTERNALSYM VERP_SUM_MONTHLY}
  VERP_SUM_MONTHLY                    = 512;
  {$EXTERNALSYM VERP_SUM_DAILY}
  VERP_SUM_DAILY                      = 1024;
  {$EXTERNALSYM VERP_PROBE}
  VERP_PROBE                          = $10000;
  {$EXTERNALSYM VERP_PROBE_WEEKLY}
  VERP_PROBE_WEEKLY                   = $20000;

type

////typedef struct
////   {
////   char lname [48];
////   char fname [128];           // Name of container file for list
////   char moderator [80];        // Primary list moderator (if any)
////   char title [80];            // Title for list (used in "to" field
////   char welcome_file [128];    // File to send to new subscribers
////   char farewell_file [128];   // File to send to unsubscribers
////   char public;                // NZ if open subscription is available
////   char matched;               // NZ if the address passed in is a moderator
////   char moderated;             // NZ if mailing to the list is restricted
////   char allow_enumeration;     // NZ if anyone may use ENUMERATE
////   char reply_to_list;         // NZ if replies should go to the list
////   int limit;                  // Maximum allowable number of subscribers
////   char errors_to [80];        // Address to which errors should be referred
////   char restricted;            // NZ if only list members may mail to the list
////   int fanout;                 // Number of jobs to "fan" the delivery to
////   char anonymous;             // Whether this list is anonymous or not
////   char title_is_address;      // If NZ, the 'title' field contains an address
////   char digest_name [14];      // Name of digest file
////   unsigned long digest_maxsize;
////   int digest_maxwait;
////   char archive_file [128];    // File into which to archive messages
////   char digest_default;        // If NZ, new users are default to digest mode
////   char list_headers;          // Use IETF draft helper headers
////   char list_help [80];        // Help URL
////   char list_signature [128];  // List's signature file
////   char concealed;             // If NZ, do not publicize via the maiser LIST
////   long maximum_size;          // Largest message that may be submitted to list
////   char password [128];        // Moderator password or password filename
////   char pwd_is_filename;       // NZ if "password" is a filename
////   char confirm_subs;          // NZ if subscription confirmation is required
////   char cs_template [80];      // Path to custom confirmation template file
////   char moderator_redirect;    // NZ to send unauthorised postings to moderator
////   char password_posting;      // NZ to require a password for posting
////   char p_password [128];      // The password to allow postings
////   char p_pwd_is_filename;     // NZ if "p_password" is a filename
////   char prefixing;             // 0/no prefix; 1/prefix; 2/suffix
////   char prefix_string [48];
////   char encryption;            // NZ to encrypt using Pegasus Mail encryption
////   char encryption_key [48];   // Encryption key for above
////   char digest_index;          // NZ to generate digest index sections
////   int autoexpiration;         // If NZ, number of days before automatic unsub
////   char disable_stripping;     // If NZ, do not strip headers from the list
////   char s_password [128];      // Subscription password
////   char s_pwd_is_filename;     // NZ if "s_password" is a filename
////   char verp_mode;             // VERP_MODE_* constant, for VERP error handling
////   int verp_maxerrs;           // Maximum delivery failures for VERP handling
////   unsigned long verp_flags;   // VERP_ERR, VERP_PROBE and VERP_SUM flags
////   char verp_filename [128];   // Template file for VERP probes, if enabled
////   unsigned long list_id;      // UID for list - used in VERP processing
////   char def_password [46];     // Default account password for new subscribers
////   char unused_1;              // Filler - not currently used.
////   char autoassign_pwds;       // If NZ, automatically assign passwords
////   DWORD lock_thread_id;       // If NZ, the thread ID of the owning thread
////   } DLIST;

  PDlist = ^TDlist;
  {$EXTERNALSYM DLIST}
  [Untested]
  DLIST = packed record
    lname: array[0..47] of AnsiChar;
    fname: array[0..127] of AnsiChar;            // Name of container file for list
    moderator: array[0..79] of AnsiChar;         // Primary list moderator (if any)
    title: array[0..79] of AnsiChar;             // Title for list (used in "to" field
    welcome_file: array[0..127] of AnsiChar;     // File to send to new subscribers
    farewell_file: array[0..127] of AnsiChar;    // File to send to unsubscribers
    public_: AnsiChar;                            // NZ if open subscription is available
    matched: AnsiChar;                           // NZ if the address passed in is a moderator
    moderated: AnsiChar;                         // NZ if mailing to the list is restricted
    allow_enumeration: AnsiChar;                 // NZ if anyone may use ENUMERATE
    reply_to_list: AnsiChar;                     // NZ if replies should go to the list
    limit: Integer;                              // Maximum allowable number of subscribers
    errors_to: array[0..79] of AnsiChar;         // Address to which errors should be referred
    restricted: AnsiChar;                        // NZ if only list members may mail to the list
    fanout: Integer;                             // Number of jobs to "fan" the delivery to
    anonymous: AnsiChar;                         // Whether this list is anonymous or not
    title_is_address: AnsiChar;                  // If NZ, the 'title' field contains an address
    digest_name: array[0..13] of AnsiChar;       // Name of digest file
    digest_maxsize: Longword;
    digest_maxwait: Integer;
    archive_file: array[0..127] of AnsiChar;     // File into which to archive messages
    digest_default: AnsiChar;                    // If NZ, new users are default to digest mode
    list_headers: AnsiChar;                      // Use IETF draft helper headers
    list_help: array[0..79] of AnsiChar;         // Help URL
    list_signature: array[0..127] of AnsiChar;   // List's signature file
    concealed: AnsiChar;                         // If NZ, do not publicize via the maiser LIST
    maximum_size: Longint;                       // Largest message that may be submitted to list
    password: array[0..127] of AnsiChar;         // Moderator password or password filename
    pwd_is_filename: AnsiChar;                   // NZ if "password" is a filename
    confirm_subs: AnsiChar;                      // NZ if subscription confirmation is required
    cs_template: array[0..79] of AnsiChar;       // Path to custom confirmation template file
    moderator_redirect: AnsiChar;                // NZ to send unauthorised postings to moderator
    password_posting: AnsiChar;                  // NZ to require a password for posting
    p_password: array[0..127] of AnsiChar;       // The password to allow postings
    p_pwd_is_filename: AnsiChar;                 // NZ if "p_password" is a filename
    prefixing: AnsiChar;                         // 0/no prefix; 1/prefix; 2/suffix
    prefix_string: array[0..47] of AnsiChar;
    encryption: AnsiChar;                        // NZ to encrypt using Pegasus Mail encryption
    encryption_key: array[0..47] of AnsiChar;    // Encryption key for above
    digest_index: AnsiChar;                      // NZ to generate digest index sections
    autoexpiration: Integer;                     // If NZ, number of days before automatic unsub
    disable_stripping: AnsiChar;                 // If NZ, do not strip headers from the list
    s_password: array[0..127] of AnsiChar;       // Subscription password
    s_pwd_is_filename: AnsiChar;                 // NZ if "s_password" is a filename
    verp_mode: AnsiChar;                         // VERP_MODE_* constant, for VERP error handling
    verp_maxerrs: Integer;                       // Maximum delivery failures for VERP handling
    verp_flags: Longword;                        // VERP_ERR, VERP_PROBE and VERP_SUM flags
    verp_filename: array[0..127] of AnsiChar;    // Template file for VERP probes, if enabled
    list_id: Longword;                           // UID for list - used in VERP processing
    def_password: array[0..45] of AnsiChar;      // Default account password for new subscribers
    unused_1: AnsiChar;                          // Filler - not currently used.
    autoassign_pwds: AnsiChar;                   // If NZ, automatically assign passwords
    lock_thread_id: DWORD;                      // If NZ, the thread ID of the owning thread
  end;
  TDlist = DLIST;

//enum
//   {
//   MSUB_DELETED = 0,           //  Record is deleted but not yet purged
//   MSUB_ACTIVE,                //  Record is active and normal
//   MSUB_NOMAIL,                //  Record is not currently receiving mail
//   MSUB_VACATION,              //  Record is timed-disabled
//   MSUB_EXCLUDED,              //  Used to prohibit subscription
//   MSUB_VERP_SUSPENDED         //  Record has been suspended by VERP
//   };

const
  {$EXTERNALSYM MSUB_S_DELETED}
  MSUB_S_DELETED                      = 1;  //  Include records marked as "deleted"
  {$EXTERNALSYM MSUB_S_ACTIVEONLY}
  MSUB_S_ACTIVEONLY                   = 2;  //  Return only records marked ACTIVE

type

////typedef struct
////   {
////   ULONG ssize;                  //  Size of this structure in bytes
////   ULONG appdata;                //  Available for application use.
////   ULONG reserved;               //  Internal use - initialize to 0
////   ULONG status;                 //  MSUB_* constants defined above
////   ULONG postings;               //  Total postings since inception
////   char address [128];
////   char name [80];
////   char comment [128];
////   char password [48];
////   UCHAR flags [16];
////   UCHAR subscription_date [8];  //  YMDHMSKx (K=Day of week, x=unused)
////   UCHAR submission_date [8];    //  Date of last submission to list
////   UCHAR vacation_date [8];      //  For status=V, auto-enable date
////   } SUBSCRIBER;

  PSubscriber = ^TSubscriber;
  {$EXTERNALSYM SUBSCRIBER}
  [Untested]
  SUBSCRIBER = packed record
    ssize: ULONG;                              //  Size of this structure in bytes
    appdata: ULONG;                            //  Available for application use.
    reserved: ULONG;                           //  Internal use - initialize to 0
    status: ULONG;                             //  MSUB_* constants defined above
    postings: ULONG;                           //  Total postings since inception
    address: array[0..127] of AnsiChar;
    name: array[0..79] of AnsiChar;
    comment: array[0..127] of AnsiChar;
    password: array[0..47] of AnsiChar;
    flags: array[0..15] of UCHAR;
    subscription_date: array[0..7] of UCHAR;   //  YMDHMSKx (K=Day of week, x=unused)
    submission_date: array[0..7] of UCHAR;     //  Date of last submission to list
    vacation_date: array[0..7] of UCHAR;      //  For status=V, auto-enable date
  end;
  TSubscriber = SUBSCRIBER;


//  The "flags" field of a SUBSCRIBER structure contains information about
//  the way the subscriber wants to receive mail. The following bytes are
//  defined:
//
//     0     'D' if the user wants to receive mail in digest mode
//     1     'N' if the user does not want to receive copies of his own posts
//     2     An error count value from 'A..Z', for 26 values
//
//  All unused bytes are reserved and must be set to '-'

//  The following values are used to select an action in the "selector"
//  parameter of "dl_bulk_update":

{$MESSAGE WARN 'Enum need conversion'}
//enum
//   {
//   DLBU_DEFPASSWORD = 1       //  Add passwords for subscribers with none defined
//   };



(****************************************************************************
  Abstracted Object Interface: this interface is the future of Mercury -
  it defines a completely extensible, object-oriented programming paradigm
  which will eventually be used to implement all internal processes in the
  program. The interface is heavily documented (see "oif.pdf") and is very
  robust and reliable. Object functions are available in Mercury versions
  4.62 and later.
****************************************************************************)

(**********************************************************************
  Section 1: Data types and enumerated constants used by this interface
**********************************************************************)


(**********************************************************************
  VERSION NUMBERS: use "OI_VERSION" in the "sversion" field of the
  object definition structure for any object you create.
**********************************************************************)

const
  {$EXTERNALSYM OI_MAJOR_VERSION}
  OI_MAJOR_VERSION                    = $10000;
  {$EXTERNALSYM OI_MINOR_VERSION}
  OI_MINOR_VERSION                    = $0003;
  {$EXTERNALSYM OI_VERSION}
  OI_VERSION                          = (OI_MAJOR_VERSION or OI_MINOR_VERSION);

  {$EXTERNALSYM MAX_ANAME_SIZE}
  MAX_ANAME_SIZE                      = 30;  //  Maximum length for an attribute name

type

//#define OIFCALL __stdcall
////typedef UINT_32 OIF_HANDLE;

  POifHandle = ^TOifHandle;
  {$EXTERNALSYM OIF_HANDLE}
  OIF_HANDLE = UINT_32;
  TOifHandle = UINT_32;

{$MESSAGE WARN 'Enum need conversion'}
//typedef enum _oif_atypes         //  Possible types for object attributes
//   {
//   OIFA_UNKNOWN,         //  Unknown attribute type
//   OIFA_STRING,          //  String type
//   OIFA_TEXT,            //  Arbitrary-length "char *" type
//   OIFA_FILENAME,        //  255-byte string containing a filename
//   OIFA_INTEGER,         //  4-byte signed integer
//   OIFA_BOOLEAN,         //  1-byte TRUE/FALSE value (1 = TRUE, 0 = FALSE)
//   OIFA_OBJECT,          //  Another type of single object
//   OIFA_CONTAINER,       //  An object that contains other objects
//   OIFA_TIME_T,          //  A unix-style "time_t" time value
//   OIFA_RECT,            //  A Windows RECT structure
//   OIFA_HWND,            //  A Windows HWND window handle.
//   OIFA_STRUCT           //  An arbitrary binary structure
//   } OIF_ATYPES;

////typedef struct
////   {
////   char aname [MAX_ANAME_SIZE];     //  Attribute name
////   UINT_32 atype;                   //  See OIF_ATYPES above
////   UINT_32 flags;                   //  Attribute flags (properties)
////   UINT_32 max_size;                //  Maximum possible size of this attribute
////   UINT_32 current_size;            //  Current size of this attribute
////   } OIF_ATTRINFO;

  POifAttrinfo = ^TOifAttrinfo;
  {$EXTERNALSYM OIF_ATTRINFO}
  [Untested]
  OIF_ATTRINFO = packed record
    aname: array[0..MAX_ANAME_SIZE - 1] of AnsiChar;  //  Attribute name
    atype: UINT_32;                                   //  See OIF_ATYPES above
    flags: UINT_32;                                   //  Attribute flags (properties)
    max_size: UINT_32;                                //  Maximum possible size of this attribute
    current_size: UINT_32;                           //  Current size of this attribute
  end;
  TOifAttrinfo = OIF_ATTRINFO;

const

//  Standard error code return values

  {$EXTERNALSYM OIERR_NO_ERROR}
  OIERR_NO_ERROR                      = 1;
  {$EXTERNALSYM OIERR_FAILED}
  OIERR_FAILED                        = - 1;
  {$EXTERNALSYM OIERR_MEMORY}
  OIERR_MEMORY                        = - 2;
  {$EXTERNALSYM OIERR_PARAM}
  OIERR_PARAM                         = - 3;
  {$EXTERNALSYM OIERR_ALREADY_REGISTERED}
  OIERR_ALREADY_REGISTERED            = - 4;
  {$EXTERNALSYM OIERR_VERSION}
  OIERR_VERSION                       = - 5;
  {$EXTERNALSYM OIERR_TOO_MANY_OBJECTS}
  OIERR_TOO_MANY_OBJECTS              = - 6; 
  {$EXTERNALSYM OIERR_NO_SUCH_OBJECT}
  OIERR_NO_SUCH_OBJECT                = - 7; 
  {$EXTERNALSYM OIERR_NOT_IMPLEMENTED}
  OIERR_NOT_IMPLEMENTED               = - 8; 
  {$EXTERNALSYM OIERR_NO_SUCH_ATTRIBUTE}
  OIERR_NO_SUCH_ATTRIBUTE             = - 9; 
  {$EXTERNALSYM OIERR_NO_MORE_RESULTS}
  OIERR_NO_MORE_RESULTS               = - 10; 
  {$EXTERNALSYM OIERR_READ_ONLY}
  OIERR_READ_ONLY                     = - 11; 
  {$EXTERNALSYM OIERR_NO_SUCH_METHOD}
  OIERR_NO_SUCH_METHOD                = - 12; 
  {$EXTERNALSYM OIERR_NOT_FOUND}
  OIERR_NOT_FOUND                     = - 13; 
  {$EXTERNALSYM OIERR_DIFFERENT_TYPES}
  OIERR_DIFFERENT_TYPES               = - 14; 
  {$EXTERNALSYM OIERR_EXISTS}
  OIERR_EXISTS                        = - 15; 
  {$EXTERNALSYM OIERR_WRITE_ERROR}
  OIERR_WRITE_ERROR                   = - 16; 
  {$EXTERNALSYM OIERR_READ_ERROR}
  OIERR_READ_ERROR                    = - 17; 
  {$EXTERNALSYM OIERR_CREATE_ERROR}
  OIERR_CREATE_ERROR                  = - 18; 
  {$EXTERNALSYM OIERR_ACCESS}
  OIERR_ACCESS                        = - 19; 
  {$EXTERNALSYM OIERR_TOO_SMALL}
  OIERR_TOO_SMALL                     = - 20; 
  {$EXTERNALSYM OIERR_TOO_MANY_USES}
  OIERR_TOO_MANY_USES                 = - 21; 
  {$EXTERNALSYM OIERR_TOO_MANY_OVERRIDES}
  OIERR_TOO_MANY_OVERRIDES            = - 21; 
  {$EXTERNALSYM OIERR_ALREADY_CHANGING}
  OIERR_ALREADY_CHANGING              = - 22; 
  {$EXTERNALSYM OIERR_NOT_CHANGING}
  OIERR_NOT_CHANGING                  = - 23; 
  {$EXTERNALSYM OIERR_NOT_CONTAINED}
  OIERR_NOT_CONTAINED                 = - 24; 
  {$EXTERNALSYM OIERR_CHARSET}
  OIERR_CHARSET                       = - 25; 
  {$EXTERNALSYM OIERR_SCAN_INTERRUPTED}
  OIERR_SCAN_INTERRUPTED              = - 26; 
  {$EXTERNALSYM OIERR_TOO_LARGE}
  OIERR_TOO_LARGE                     = - 27; 
  {$EXTERNALSYM OIERR_ILLEGAL_OPERATION}
  OIERR_ILLEGAL_OPERATION             = - 28; 
  {$EXTERNALSYM OIERR_NOT_SUPPORTED}
  OIERR_NOT_SUPPORTED                 = - 29; 
  {$EXTERNALSYM OIERR_USER}
  OIERR_USER                          = - 2048; 

//  Comparison flags you can pass to "oif_compare_str"

  {$EXTERNALSYM OIFC_CASE_SENSITIVE}
  OIFC_CASE_SENSITIVE                 = 1; 
  {$EXTERNALSYM OIFC_IGNORE_SYMBOLS}
  OIFC_IGNORE_SYMBOLS                 = 2; 
  {$EXTERNALSYM OIFC_STRINGSORT}
  OIFC_STRINGSORT                     = 4;

type

(**********************************************************************
  Section 2: Client-side functions
  These are the functions that code designed to use the interface will
  call to interact with objects.
**********************************************************************)
{$MESSAGE WARN 'These routines could likely be cdecl, and not stdcall!!!'}
// INT_32 (OIFCALL *OIF_NEW) (const char *name, const char *type, OIF_HANDLE *object, UINT_32 flags);
{$EXTERNALSYM OIF_NEW}
  [Untested]
  OIF_NEW = function (name: PAnsiChar; &type: PAnsiChar; var obj: OIF_HANDLE; flags: UINT_32): INT_32; stdcall;

// INT_32 OIF_DISPOSE_HANDLE (OIF_HANDLE object);
{$EXTERNALSYM OIF_DISPOSE_HANDLE}
  [Untested]
  OIF_DISPOSE_HANDLE = function (obj: OIF_HANDLE): INT_32; stdcall;

// INT_32 OIF_USE_HANDLE (OIF_HANDLE object);
{$EXTERNALSYM OIF_USE_HANDLE}
  [Untested]
  OIF_USE_HANDLE = function (obj: OIF_HANDLE): INT_32; stdcall;

// INT_32 OIF_DUPLICATE_OBJECT (OIF_HANDLE object, OIF_HANDLE *dup_object);

{$EXTERNALSYM OIF_DUPLICATE_OBJECT}
  [Untested]
  OIF_DUPLICATE_OBJECT = function (obj: OIF_HANDLE; var dup_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_COMPARE (OIF_HANDLE object1, OIF_HANDLE object2, const char *aname, INT_32 *result);

{$EXTERNALSYM OIF_COMPARE}
  [Untested]
  OIF_COMPARE = function (object1: OIF_HANDLE; object2: OIF_HANDLE; aname: PAnsiChar; var result: INT_32): INT_32; stdcall;

////INT_32 OIF_COMPARE_STR (OIF_HANDLE object1, OIF_HANDLE object2,
////   const char *aname, UINT_32 flags, INT_32 *result);

{$EXTERNALSYM OIF_COMPARE_STR}
  [Untested]
  OIF_COMPARE_STR = function (object1: OIF_HANDLE; object2: OIF_HANDLE;
  aname: PAnsiChar; flags: UINT_32; var result: INT_32): INT_32; stdcall;

////INT_32 OIF_HAS_TYPE (OIF_HANDLE object, const char *otype);

{$EXTERNALSYM OIF_HAS_TYPE}
  [Untested]
  OIF_HAS_TYPE = function (obj: OIF_HANDLE; otype: PAnsiChar): INT_32; stdcall;

////INT_32 OIF_LOCK (OIF_HANDLE object);

{$EXTERNALSYM OIF_LOCK}
  [Untested]
  OIF_LOCK = function (obj: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_UNLOCK (OIF_HANDLE object);

{$EXTERNALSYM OIF_UNLOCK}
  [Untested]
  OIF_UNLOCK = function (obj: OIF_HANDLE): INT_32; stdcall;


////INT_32 OIF_GET_ATTRIBUTE (OIF_HANDLE object, const char *aname, void *buffer, UINT_32 buflen);

{$EXTERNALSYM OIF_GET_ATTRIBUTE}
  [Untested]
  OIF_GET_ATTRIBUTE = function (obj: OIF_HANDLE; aname: PAnsiChar; buffer: Pointer; buflen: UINT_32): INT_32; stdcall;

////  INT_32 OIF_GET_ATTRIBUTE_INFO (OIF_HANDLE object, const char *aname, OIF_ATTRINFO *oia);

{$EXTERNALSYM OIF_GET_ATTRIBUTE_INFO}
  [Untested]
  OIF_GET_ATTRIBUTE_INFO = function (obj: OIF_HANDLE; aname: PAnsiChar; var oia: OIF_ATTRINFO): INT_32; stdcall;

////INT_32 OIF_SET_ATTRIBUTE (OIF_HANDLE object, const char *aname, void *buffer, UINT_32 buflen);

{$EXTERNALSYM OIF_SET_ATTRIBUTE}
  [Untested]
  OIF_SET_ATTRIBUTE = function (obj: OIF_HANDLE; aname: PAnsiChar; buffer: Pointer; buflen: UINT_32): INT_32; stdcall;


////INT_32 OIF_DO_METHOD (OIF_HANDLE object, const char *mname,
////   const void *inbuf, UINT_32 iblen, void *outbuf, UINT_32 oblen);

{$EXTERNALSYM OIF_DO_METHOD}
  [Untested]
  OIF_DO_METHOD = function (obj: OIF_HANDLE; mname: PAnsiChar;
  inbuf: Pointer; iblen: UINT_32; outbuf: Pointer; oblen: UINT_32): INT_32; stdcall;


////INT_32 OIF_SCAN_FIRST (OIF_HANDLE container, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SCAN_FIRST}
  [Untested]
  OIF_SCAN_FIRST = function (container: OIF_HANDLE; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_SCAN_LAST (OIF_HANDLE container, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SCAN_LAST}
  OIF_SCAN_LAST = function (container: OIF_HANDLE; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_SCAN_NEXT (OIF_HANDLE container, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SCAN_NEXT}
  OIF_SCAN_NEXT = function (container: OIF_HANDLE; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_SCAN_PREV (OIF_HANDLE container, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SCAN_PREV}
  OIF_SCAN_PREV = function (container: OIF_HANDLE; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_END_SCAN (OIF_HANDLE container, UINTP *ref);

{$EXTERNALSYM OIF_END_SCAN}
  OIF_END_SCAN = function (container: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;


////INT_32 OIF_SEARCH_FIRST (OIF_HANDLE container, const char *expression,
////   UINT_32 explen, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SEARCH_FIRST}
  OIF_SEARCH_FIRST = function (container: OIF_HANDLE; expression: PAnsiChar;
  explen: UINT_32; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_SEARCH_NEXT (OIF_HANDLE container, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OIF_SEARCH_NEXT}
  OIF_SEARCH_NEXT = function (container: OIF_HANDLE; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_END_SEARCH (OIF_HANDLE container, UINTP *ref);

{$EXTERNALSYM OIF_END_SEARCH}
  OIF_END_SEARCH = function (container: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OIF_ADD (OIF_HANDLE container, const char *name, const char *type,
////   OIF_HANDLE *new_object, UINT_32 flags);

{$EXTERNALSYM OIF_ADD}
  OIF_ADD = function (container: OIF_HANDLE; name: PAnsiChar; &type: PAnsiChar;
  var new_object: OIF_HANDLE; flags: UINT_32): INT_32; stdcall;

////INT_32 OIF_ADDTO (OIF_HANDLE container, OIF_HANDLE object,
////   OIF_HANDLE *new_object);

{$EXTERNALSYM OIF_ADDTO}
  OIF_ADDTO = function (container: OIF_HANDLE; obj: OIF_HANDLE;
  var new_object: OIF_HANDLE): INT_32; stdcall;


////INT_32 OIF_DELETE (OIF_HANDLE object);

{$EXTERNALSYM OIF_DELETE}
  OIF_DELETE = function (obj: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_CHANGE (OIF_HANDLE object, OIF_HANDLE *change_object);

{$EXTERNALSYM OIF_CHANGE}
  OIF_CHANGE = function (obj: OIF_HANDLE; var change_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_COMMIT_CHANGES (OIF_HANDLE object, OIF_HANDLE change_object);

{$EXTERNALSYM OIF_COMMIT_CHANGES}
  OIF_COMMIT_CHANGES = function (obj: OIF_HANDLE; change_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_CANCEL_CHANGES (OIF_HANDLE object, OIF_HANDLE change_object);

{$EXTERNALSYM OIF_CANCEL_CHANGES}
  OIF_CANCEL_CHANGES = function (obj: OIF_HANDLE; change_object: OIF_HANDLE): INT_32; stdcall;


(**********************************************************************
  Section 3: Object implementation functions
  Object implementation code passes a block of these routines to the
  Object Interface Management code during registration, and they are
  subsequently called by the Interface Management code... So, when a
  client calls "oif_get_attribute", the Interface Management code
  pulls up the object, locates the function block that was registered
  for that object, then calls the "oii_get_attribute" member.
**********************************************************************)
////INT_32 OII_NEW (const char *name, const char *type, OIF_HANDLE *object, UINT_32 flags);

{$EXTERNALSYM OII_NEW}
  OII_NEW = function (name: PAnsiChar; &type: PAnsiChar; var obj: OIF_HANDLE; flags: UINT_32): INT_32; stdcall;
  
////INT_32 OII_DISPOSE (OIF_HANDLE object, UINTP objdata);

{$EXTERNALSYM OII_DISPOSE}
  OII_DISPOSE = function (obj: OIF_HANDLE; objdata: UINTP): INT_32; stdcall;

////INT_32 OII_DUPLICATE_OBJECT (OIF_HANDLE object, UINTP objdata, OIF_HANDLE *dup_object);

{$EXTERNALSYM OII_DUPLICATE_OBJECT}
  OII_DUPLICATE_OBJECT = function (obj: OIF_HANDLE; objdata: UINTP; var dup_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OII_COMPARE (OIF_HANDLE object1, UINTP o1data,
////   OIF_HANDLE object2, UINTP o2data, const char *aname, INT_32 *result);

{$EXTERNALSYM OII_COMPARE}
  OII_COMPARE = function (object1: OIF_HANDLE; o1data: UINTP;
  object2: OIF_HANDLE; o2data: UINTP; aname: PAnsiChar; var result: INT_32): INT_32; stdcall;

////INT_32 OII_LOCK (OIF_HANDLE object, UINTP objdata);

{$EXTERNALSYM OII_LOCK}
  OII_LOCK = function (obj: OIF_HANDLE; objdata: UINTP): INT_32; stdcall;

////INT_32 OII_UNLOCK (OIF_HANDLE object, UINTP objdata);

{$EXTERNALSYM OII_UNLOCK}
  OII_UNLOCK = function (obj: OIF_HANDLE; objdata: UINTP): INT_32; stdcall;

////INT_32 OII_GET_ATTRIBUTE (OIF_HANDLE object, UINTP objdata, const char *aname,
////   void *buffer, UINT_32 buflen);

{$EXTERNALSYM OII_GET_ATTRIBUTE}
  OII_GET_ATTRIBUTE = function (obj: OIF_HANDLE; objdata: UINTP; aname: PAnsiChar;
  buffer: Pointer; buflen: UINT_32): INT_32; stdcall;

////INT_32 OII_GET_ATTRIBUTE_INFO (OIF_HANDLE object, UINTP objdata,
////   const char *aname, OIF_ATTRINFO *oia);

{$EXTERNALSYM OII_GET_ATTRIBUTE_INFO}
  OII_GET_ATTRIBUTE_INFO = function (obj: OIF_HANDLE; objdata: UINTP;
  aname: PAnsiChar; var oia: OIF_ATTRINFO): INT_32; stdcall;

////INT_32 OII_SET_ATTRIBUTE (OIF_HANDLE object, UINTP objdata, const char *aname,
////   void *buffer, UINT_32 buflen);

{$EXTERNALSYM OII_SET_ATTRIBUTE}
  OII_SET_ATTRIBUTE = function (obj: OIF_HANDLE; objdata: UINTP; aname: PAnsiChar;
  buffer: Pointer; buflen: UINT_32): INT_32; stdcall;


////INT_32 OII_DO_METHOD (OIF_HANDLE object, UINTP objdata, const char *mname,
////   const void *inbuf, UINT_32 iblen, void *outbuf, UINT_32 oblen);

{$EXTERNALSYM OII_DO_METHOD}
  OII_DO_METHOD = function (obj: OIF_HANDLE; objdata: UINTP; mname: PAnsiChar;
  inbuf: Pointer; iblen: UINT_32; outbuf: Pointer; oblen: UINT_32): INT_32; stdcall;

////INT_32 OII_SCAN_FIRST (OIF_HANDLE container, UINTP cdata, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SCAN_FIRST}
  OII_SCAN_FIRST = function (container: OIF_HANDLE; cdata: UINTP; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_SCAN_LAST (OIF_HANDLE container, UINTP cdata, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SCAN_LAST}
  OII_SCAN_LAST = function (container: OIF_HANDLE; cdata: UINTP; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_SCAN_NEXT (OIF_HANDLE container, UINTP cdata, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SCAN_NEXT}
  OII_SCAN_NEXT = function (container: OIF_HANDLE; cdata: UINTP; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_SCAN_PREV (OIF_HANDLE container, UINTP cdata, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SCAN_PREV}
  OII_SCAN_PREV = function (container: OIF_HANDLE; cdata: UINTP; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_END_SCAN (OIF_HANDLE container, UINTP cdata, UINTP *ref);

{$EXTERNALSYM OII_END_SCAN}
  OII_END_SCAN = function (container: OIF_HANDLE; cdata: UINTP; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_SEARCH_FIRST (OIF_HANDLE container, UINTP cdata,
////   const char *expression, UINT_32 explen, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SEARCH_FIRST}
  OII_SEARCH_FIRST =function (container: OIF_HANDLE; cdata: UINTP;
  expression: PAnsiChar; explen: UINT_32; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_SEARCH_NEXT (OIF_HANDLE container, UINTP cdata, OIF_HANDLE *object, UINTP *ref);

{$EXTERNALSYM OII_SEARCH_NEXT}
  OII_SEARCH_NEXT = function (container: OIF_HANDLE; cdata: UINTP; var obj: OIF_HANDLE; var ref: UINTP): INT_32; stdcall;

////INT_32 OII_END_SEARCH (OIF_HANDLE container, UINTP cdata, UINTP *ref);

{$EXTERNALSYM OII_END_SEARCH}
  OII_END_SEARCH = function (container: OIF_HANDLE; cdata: UINTP; var ref: UINTP): INT_32; stdcall;


////INT_32 OII_ADD (OIF_HANDLE container, UINTP cdata, const char *name,
////   const char *type, OIF_HANDLE *new_object, UINT_32 flags);

{$EXTERNALSYM OII_ADD}
  OII_ADD = function (container: OIF_HANDLE; cdata: UINTP; name: PAnsiChar;
  &type: PAnsiChar; var new_object: OIF_HANDLE; flags: UINT_32): INT_32; stdcall;

////INT_32 OII_ADDTO (OIF_HANDLE container, UINTP cdata,
////   OIF_HANDLE object, UINTP odata, OIF_HANDLE *new_object);

{$EXTERNALSYM OII_ADDTO}
  OII_ADDTO = function (container: OIF_HANDLE; cdata: UINTP;
  obj: OIF_HANDLE; odata: UINTP; var new_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OII_DELETE (UINTP cdata, OIF_HANDLE object, UINTP odata);

{$EXTERNALSYM OII_DELETE}
  OII_DELETE = function (cdata: UINTP; obj: OIF_HANDLE; odata: UINTP): INT_32; stdcall;

////INT_32 OII_CHANGE (UINTP cdata, OIF_HANDLE object, UINTP odata,
////   OIF_HANDLE *change_object);

{$EXTERNALSYM OII_CHANGE}
  OII_CHANGE = function (cdata: UINTP; obj: OIF_HANDLE; odata: UINTP;
  var change_object: OIF_HANDLE): INT_32; stdcall;

////INT_32 OII_COMMIT_CHANGES (UINTP cdata, OIF_HANDLE object, UINTP odata,
////   OIF_HANDLE change_object, UINTP codata);

{$EXTERNALSYM OII_COMMIT_CHANGES}
  OII_COMMIT_CHANGES = function (cdata: UINTP; obj: OIF_HANDLE; odata: UINTP;
  change_object: OIF_HANDLE; codata: UINTP): INT_32; stdcall;

////INT_32 OII_CANCEL_CHANGES (UINTP cdata, OIF_HANDLE object, UINTP odata,
////   OIF_HANDLE change_object, UINTP codata);

{$EXTERNALSYM OII_CANCEL_CHANGES}
  OII_CANCEL_CHANGES = function (cdata: UINTP; obj: OIF_HANDLE; odata: UINTP;
  change_object: OIF_HANDLE; codata: UINTP): INT_32; stdcall;


////INT_32 OII_SHUTDOWN (void);

{$EXTERNALSYM OII_SHUTDOWN}
  OII_SHUTDOWN = function: INT_32; stdcall;

const

  {$EXTERNALSYM OIIF_NEEDS_DISAMBIGUATION}
  OIIF_NEEDS_DISAMBIGUATION           = 1;  //  Object wants to see disambiguation operators
  {$EXTERNALSYM OIIF_OVERRIDES_ONLY}
  OIIF_OVERRIDES_ONLY                 = 2;  //  Definition is only used for overriding objects
  {$EXTERNALSYM OIIF_BASIC_COMPARE_ONLY}
  OIIF_BASIC_COMPARE_ONLY             = 4;  //  Definition only supports same-object oii_compare
  {$EXTERNALSYM OIIF_USE_CRITICAL_SECTION}
  OIIF_USE_CRITICAL_SECTION           = 8;  //  Definition wants to enable critical section usage

type
////typedef struct
////   {
////   UINT_32 sversion;
////   UINT_32 flags;
////   char oname [30];
////   char otypes [256];
////   CRITICAL_SECTION csec;
////
////   OII_NEW oii_new;
////   OII_DISPOSE oii_dispose;
////   OII_DUPLICATE_OBJECT oii_duplicate_object;   //  Not currently used - set to NULL
////   OII_COMPARE oii_compare;
////
////   OII_LOCK oii_lock;                           //  Optional
////   OII_UNLOCK oii_unlock;                       //  Optional
////
////   OII_GET_ATTRIBUTE oii_get_attribute;
////   OII_GET_ATTRIBUTE_INFO oii_get_attribute_info;
////   OII_SET_ATTRIBUTE oii_set_attribute;
////
////   OII_DO_METHOD oii_do_method;
////
////   OII_SCAN_FIRST oii_scan_first;               //  Container objects only
////   OII_SCAN_LAST oii_scan_last;                 //  Container objects only
////   OII_SCAN_NEXT oii_scan_next;                 //  Container objects only
////   OII_SCAN_PREV oii_scan_prev;                 //  Container objects only
////   OII_END_SCAN oii_end_scan;                   //  Container objects only
////
////   OII_SEARCH_FIRST oii_search_first;           //  Optional, containers only
////   OII_SEARCH_NEXT oii_search_next;             //  Optional, containers only
////   OII_END_SEARCH oii_end_search;               //  Optional, containers only
////
////   OII_ADD oii_add;                             //  Container objects only
////   OII_ADDTO oii_addto;                         //  Container objects only
////   OII_DELETE oii_delete;                       //  Optional unless container
////   OII_CHANGE oii_change;                       //  Optional unless container
////   OII_COMMIT_CHANGES oii_commit_changes;       //  Optional unless container
////   OII_CANCEL_CHANGES oii_cancel_changes;       //  Optional unless container
////
////   OII_SHUTDOWN oii_shutdown;                   //  Optional
////   } OIF_OBJECT_DEFINITION;

  POifObjectDefinition = ^TOifObjectDefinition;
  {$EXTERNALSYM OIF_OBJECT_DEFINITION}
  OIF_OBJECT_DEFINITION = packed record
    sversion: UINT_32;
    flags: UINT_32;
    oname: array[0..29] of AnsiChar;
    otypes: array[0..255] of AnsiChar;
{$MESSAGE WARN 'Convert CRITICAL_SECTION'}
//    csec: CRITICAL_SECTION;
    oii_new: OII_NEW;
    oii_dispose: OII_DISPOSE;
    oii_duplicate_object: OII_DUPLICATE_OBJECT;  //  Not currently used - set to NULL
    oii_compare: OII_COMPARE;
    oii_lock: OII_LOCK;                          //  Optional
    oii_unlock: OII_UNLOCK;                      //  Optional
    oii_get_attribute: OII_GET_ATTRIBUTE;
    oii_get_attribute_info: OII_GET_ATTRIBUTE_INFO;
    oii_set_attribute: OII_SET_ATTRIBUTE;
    oii_do_method: OII_DO_METHOD;
    oii_scan_first: OII_SCAN_FIRST;              //  Container objects only 
    oii_scan_last: OII_SCAN_LAST;                //  Container objects only 
    oii_scan_next: OII_SCAN_NEXT;                //  Container objects only 
    oii_scan_prev: OII_SCAN_PREV;                //  Container objects only 
    oii_end_scan: OII_END_SCAN;                  //  Container objects only 
    oii_search_first: OII_SEARCH_FIRST;          //  Optional, containers only 
    oii_search_next: OII_SEARCH_NEXT;            //  Optional, containers only 
    oii_end_search: OII_END_SEARCH;              //  Optional, containers only 
    oii_add: OII_ADD;                            //  Container objects only 
    oii_addto: OII_ADDTO;                        //  Container objects only 
    oii_delete: OII_DELETE;                      //  Optional unless container 
    oii_change: OII_CHANGE;                      //  Optional unless container 
    oii_commit_changes: OII_COMMIT_CHANGES;      //  Optional unless container 
    oii_cancel_changes: OII_CANCEL_CHANGES;      //  Optional unless container 
    oii_shutdown: OII_SHUTDOWN;                 //  Optional 
  end; 
  TOifObjectDefinition = OIF_OBJECT_DEFINITION; 


(**********************************************************************
  Section 4: Object-side functions
  These are the functions that code that implements objects will call
  to interact with the interface manager.
**********************************************************************)

////INT_32 OIF_REGISTER (const OIF_OBJECT_DEFINITION *oifd);

{$EXTERNALSYM OIF_REGISTER}
  OIF_REGISTER = function (var oifd: OIF_OBJECT_DEFINITION): INT_32; stdcall;

////INT_32 OIF_MAKE_HANDLE (INT_32 objdef, UINTP data, OIF_HANDLE *object);

{$EXTERNALSYM OIF_MAKE_HANDLE}
  OIF_MAKE_HANDLE = function (objdef: INT_32; data: UINTP; var obj: OIF_HANDLE): INT_32; stdcall;

////INT_32 OIF_CHANGE_DATA (OIF_HANDLE object, UINTP old_data, UINTP new_data);

{$EXTERNALSYM OIF_CHANGE_DATA}
  OIF_CHANGE_DATA = function (obj: OIF_HANDLE; old_data: UINTP; new_data: UINTP): INT_32; stdcall;


////INT_32 OIF_RECREATE_OBJECT (const void *data, UINT_32 dlen,
////   OIF_HANDLE *object, UINT_32 cdef, UINTP cdata);

{$EXTERNALSYM OIF_RECREATE_OBJECT}
  OIF_RECREATE_OBJECT = function (data: Pointer; dlen: UINT_32;
  var obj: OIF_HANDLE; cdef: UINT_32; cdata: UINTP): INT_32; stdcall;


////INT_32 OIF_OVERRIDE_OBJECT (OIF_HANDLE object, INT_32 objdef, UINTP data);

{$EXTERNALSYM OIF_OVERRIDE_OBJECT}
  OIF_OVERRIDE_OBJECT = function (obj: OIF_HANDLE; objdef: INT_32; data: UINTP): INT_32; stdcall;

////INT_32 OIF_UNOVERRIDE_OBJECT (OIF_HANDLE object, INT_32 objdef, UINTP data);

{$EXTERNALSYM OIF_UNOVERRIDE_OBJECT}
  OIF_UNOVERRIDE_OBJECT = function (obj: OIF_HANDLE; objdef: INT_32; data: UINTP): INT_32; stdcall;

const

(****************************************************************************
  The core protocol module data structures: this section defines the basic
  interface between Mercury and its satellites, whether they be protocol
  modules or Daemons. When Mercury loads and invokes your module, it
  passes you an instance of the M_INTERFACE structure defined below: this
  structure contains function pointers to all the functions defined by
  this interface, and you should store a copy of it somewhere in your
  module's address space, because you will use it heavily.

  For your programming convenience, a naming scheme based on macros is
  also defined below. To use this, simply create a global variable called
  "mi" of type "M_INTERFACE *" and assign your copy of the protocol block
  to that variable. With this done, you can now reference the functions
  in the protocol block using just their names (no structure reference
  required). Remember to declare your "mi" variable "extern" in any
  source files or header files outside the one where it is declared.
****************************************************************************)

  {$EXTERNALSYM ONLINE_STATE}
  ONLINE_STATE                        = 1; 
  {$EXTERNALSYM KICKSTART}
  KICKSTART                           = 2; 
  {$EXTERNALSYM TCP_IDLE}
  TCP_IDLE                            = 4; 

//  Constants that can be passed to "get_variable" to
//  yield system-level information.

  {$EXTERNALSYM GV_QUEUENAME}
  GV_QUEUENAME                        = 1; 
  {$EXTERNALSYM GV_SMTPQUEUENAME}
  GV_SMTPQUEUENAME                    = 2; 
  {$EXTERNALSYM GV_MYNAME}
  GV_MYNAME                           = 3; 
  {$EXTERNALSYM GV_TTYFONT}
  GV_TTYFONT                          = 4; 
  {$EXTERNALSYM GV_MAISERNAME}
  GV_MAISERNAME                       = 5; 
  {$EXTERNALSYM GV_FRAMEWINDOW}
  GV_FRAMEWINDOW                      = 6; 
  {$EXTERNALSYM GV_SYSFONT}
  GV_SYSFONT                          = 7; 
  {$EXTERNALSYM GV_BASEDIR}
  GV_BASEDIR                          = 8; 
  {$EXTERNALSYM GV_SCRATCHDIR}
  GV_SCRATCHDIR                       = 9; 
  {$EXTERNALSYM GV_EXEDIR}
  GV_EXEDIR                           = 10; 

//  Constants that can be passed to "create_object"

  {$EXTERNALSYM OBJ_USER}
  OBJ_USER                            = 1; 
  {$EXTERNALSYM OBJ_ADMINISTRATOR}
  OBJ_ADMINISTRATOR                   = 2; 

  {$EXTERNALSYM SYSTEM_PASSWORD}
  SYSTEM_PASSWORD                     = 1;
  {$EXTERNALSYM APOP_SECRET}
  APOP_SECRET                         = 2;
  {$EXTERNALSYM PASSWD_MUST_EXIST}
  PASSWD_MUST_EXIST                   = 256; 


//  Message creation constants, for use with the various "om_..."
//  message composition functions in MESSAGE.C

  {$EXTERNALSYM OM_M_8BIT}
  OM_M_8BIT                           = 1; 

    {$EXTERNALSYM OM_MT_PLAIN}
  OM_MT_PLAIN                         = 0;  //  A simple, single-part text/plain message
  {$EXTERNALSYM OM_MT_MULTIPART}
  OM_MT_MULTIPART                     = 1;  //  A multipart/mixed message
  {$EXTERNALSYM OM_MT_ALTERNATIVE}
  OM_MT_ALTERNATIVE                   = 2;  //  A multipart/alternative message
  {$EXTERNALSYM OM_MT_DIGEST}
  OM_MT_DIGEST                        = 3;  //  A multipart/digest type

  {$EXTERNALSYM OM_MF_TO}
  OM_MF_TO                            = 1;  //  Set the master recipient of the message
  {$EXTERNALSYM OM_MF_SUBJECT}
  OM_MF_SUBJECT                       = 2;  //  Set the subject field for the message
  {$EXTERNALSYM OM_MF_CC}
  OM_MF_CC                            = 3;  //  Set the secondary recipients of the message
  {$EXTERNALSYM OM_MF_FROM}
  OM_MF_FROM                          = 4;  //  Set the originator of the message.
  {$EXTERNALSYM OM_MF_BODY}
  OM_MF_BODY                          = 5;  //  Set the filename containing the message body
  {$EXTERNALSYM OM_MF_RAW}
  OM_MF_RAW                           = 6;  //  Add a raw header for the message.
  {$EXTERNALSYM OM_MF_FLAGS}
  OM_MF_FLAGS                         = 7;  //  Set the message's "flags" field
  {$EXTERNALSYM OM_MF_RESUBJECT}
  OM_MF_RESUBJECT                     = 8;  //  Set the subject line as if replying
  {$EXTERNALSYM OM_MF_JOBFLAGS}
  OM_MF_JOBFLAGS                      = 9;  //  Set job processing flags on creation

  {$EXTERNALSYM OM_AE_DEFAULT}
  OM_AE_DEFAULT                       = 0;  //  Default encoding (MIME BASE64 encoding)
  {$EXTERNALSYM OM_AE_TEXT}
  OM_AE_TEXT                          = 1;  //  Simple textual data, unencoded
  {$EXTERNALSYM OM_AE_UUENCODE}
  OM_AE_UUENCODE                      = 2;  //  Uuencoding
  {$EXTERNALSYM OM_AE_BINHEX}
  OM_AE_BINHEX                        = 3;  //  Macintosh Binhex format (data fork only)

  {$EXTERNALSYM OM_AF_INLINE}
  OM_AF_INLINE                        = 1;  //  Write the file as a simple textual section
  {$EXTERNALSYM OM_AF_MESSAGE}
  OM_AF_MESSAGE                       = 2;  //  Write the message as a Message/RFC822 part


//  Messages that protocol modules can send using the
//  "mercury_command" function in the protocol parameter block

//  GET_MODULE_INTERFACE:
//    - "parm1" - char * pointer to name of module to locate
//    - Returns: the command interface function for the module, or NULL
  {$EXTERNALSYM GET_MODULE_INTERFACE}
  GET_MODULE_INTERFACE                = 1; 

//  ADD_ALIAS
//    - "parm1" - char * pointer to alias to add
//      "parm2" - char * pointer to real-world address string
//    - Returns: NZ on success, 0 on failure
  {$EXTERNALSYM ADD_ALIAS}
  ADD_ALIAS                           = 2; 

//  DELETE_ALIAS
//    - "parm1" - char * pointer to alias field of alias to delete
//    - Returns: NZ on success, 0 on failure
  {$EXTERNALSYM DELETE_ALIAS}
  DELETE_ALIAS                        = 3; 

//  RESOLVE_ALIAS
//    - "parm1" - char * pointer to buffer to receive address (180 char min)
//      "parm2" - char * pointer to alias to resolve
//    - Returns: NZ if a match was found, 0 if none was found.
  {$EXTERNALSYM RESOLVE_ALIAS}
  RESOLVE_ALIAS                       = 4;

//  RESOLVE_SYNONYM
//    - "parm1" - char * pointer to buffer to receive address (180 char min)
//      "parm2" - char * pointer to synonym to resolve
//    - Returns: NZ if a match was found, 0 if none was found
  {$EXTERNALSYM RESOLVE_SYNONYM}
  RESOLVE_SYNONYM                     = 5; 

//  DISPLAY_HELP
//    - "parm1" - section number in MERCURY.HLP
//      "parm2" - unused, must be 0
//    - Returns:  Nothing.
  {$EXTERNALSYM DISPLAY_HELP}
  DISPLAY_HELP                        = 512; 

//  QUEUE_STATE - enable or disable queue processing
//    - "parm1" - 0 to query current state, 1 to set state
//      "parm2" - 1 to pause processing, 0 to enable it
//    - Returns:  The state of queue processing prior to the call
  {$EXTERNALSYM QUEUE_STATE}
  QUEUE_STATE                         = 6; 

//  GET_TEMPFILE - get a temporary filename (guaranteed not to exist)
//    - "parm1" - a (char *) buffer at least 128 characters long
//      "parm2" - unused, must be 0
//    - Returns: 1 on success, 0 on failure
  {$EXTERNALSYM GET_TEMPFILE}
  GET_TEMPFILE                        = 7; 

//  CREATE_MDI_WINDOW - create a Mercury/32 MDI window to host a dialog.
//    - "parm1" - an HWND, a modeless child dialog that should be
//      imbedded within the MDI window.
//      "parm2" - unused, must be 0
//    - Returns: HWND of MDI window on success, 0 on failure.
  {$EXTERNALSYM CREATE_MDI_WINDOW}
  CREATE_MDI_WINDOW                   = 8; 

//  SET_LINGER - enable, disable or query the setting for the folder
//  management layer's "lingering mailbox" feature.
//    - "parm1" - 0 to disable, 1 to enable, -1 to query
//      "parm2" - if non-zero, points to integer for linger timeout in seconds
//    - Returns: the previous linger setting
  {$EXTERNALSYM SET_LINGER}
  SET_LINGER                          = 9; 

  {$EXTERNALSYM NOT_IMPLEMENTED}
  NOT_IMPLEMENTED                     = $F0000000;

  {$EXTERNALSYM RFC_822_TIME}
  RFC_822_TIME                        = 0; 
  {$EXTERNALSYM RFC_821_TIME}
  RFC_821_TIME                        = 1; 

type

////typedef struct
////   {
////   char modname [12];      //  Module's "identity".
////   char fname [128];       //  DLL load filename
////   HINSTANCE hModule;      //  DLL instance handle
////   unsigned long flags;
////   char menuname [32];     //  "Configuration" menu entry text
////   union
////      {
////      struct
////         {
////         HWND hMDIParent;        //  Module's MDI window, if any.
////         HWND hDialog;           //  Module's dialog, if any.
////         } wnd;
////      OIF_HANDLE console;
////      } ui;
////   int menu_id;            //  ID of "Configuration" menu entry
////   void *data;             //  For the module's use if required
////   } PMODULE;

  PPmodule = ^TPmodule;
  {$EXTERNALSYM PMODULE}
  PMODULE = packed record
    modname: array[0..11] of AnsiChar;    //  Module's "identity".
    fname: array[0..127] of AnsiChar;     //  DLL load filename
    hModule: HINST;                       //  DLL instance handle
    flags: Longword;
    menuname: array[0..31] of AnsiChar;   //  "Configuration" menu entry text
    ui: packed record
      wnd: packed record
        hMDIParent: HWND;                 //  Module's MDI window, if any.
        hDialog: HWND;                    //  Module's dialog, if any.
      end;
      console: OIF_HANDLE;
    end;
    menu_id: Integer;                     //  ID of "Configuration" menu entry
    data: Pointer;                       //  For the module's use if required
  end;
  TPmodule = PMODULE;

//typedef void (*DEPRECATED_FUNCTION) (void);
  {$EXTERNALSYM DEPRECATED_FUNCTION}
  DEPRECATED_FUNCTION = procedure; cdecl;

// typedef UINTP (*GET_VARIABLE) (int index);
  {$EXTERNALSYM GET_VARIABLE}
  GET_VARIABlE = function(Index: INT_16): UINTP; cdecl;

// typedef int (*IS_LOCAL_ADDRESS) (char *address, char *uic, char *server);
  {$EXTERNALSYM IS_LOCAL_ADDRESS}
  IS_LOCAL_ADDRESS = function(Address, UIC, Server: PAnsiChar): INT_16; cdecl;

// typedef int (*GET_DELIVERY_PATH) (char *path, char *username, char *host);
  {$EXTERNALSYM GET_DELIVERY_PATH}
  GET_DELIVERY_PATH = function(Path, UserName, Host: PAnsiChar): INT_16; cdecl;

// typedef int (*IS_GROUP) (char *address, char *host, char *groupname);
  {$EXTERNALSYM IS_GROUP}
  IS_GROUP = function(Address, Host, GroupName: PAnsiChar): INT_16; cdecl;

// typedef int (*PARSE_ADDRESS) (char *target, char *source, int limit);
  {$EXTERNALSYM PARSE_ADDRESS}
  PARSE_ADDRESS = function(Target, Source: PAnsiChar; Limit: INT_16): INT_16; cdecl;

// typedef int (*EXTRACT_ONE_ADDRESS) (char *dest, char *source, int offset);
  {$EXTERNALSYM EXTRACT_ONE_ADDRESS}
  EXTRACT_ONE_ADDRESS = function(Dest, Source: PAnsiChar; Offset: INT_16): INT_16; cdecl;

// typedef void (*EXTRACT_CQTEXT) (char *dest, char *source, int len);
  {$EXTERNALSYM EXTRACT_CQTEXT}
  EXTRACT_CQTEXT = procedure(Dest, Source: PAnsiChar; Len: INT_16); cdecl;

// typedef int (*DLIST_INFO) (DLIST *dlist, char *lname, int num, char *address, char *errbuf, LIST *modlist);
  {$EXTERNALSYM DLIST_INFO}
  DLIST_INFO = function(Dlist: PDlist; LName: PAnsiChar; Num: INT_16; Address,
    ErrBuf: PAnsiChar; ModList: PList): INT_16; cdecl;

// typedef int (*DLIST_COUNT) (UINT_32 flags);
  {$EXTERNALSYM DLIST_COUNT}
  DLIST_COUNT = function(Flags: UINT_32): INT_16; cdecl;

// typedef void (*SEND_NOTIFICATION) (char *username, char *host, char *message);
  {$EXTERNALSYM SEND_NOTIFICATION}
  SEND_NOTIFICATION = procedure (UserName, Host, Message: PAnsiChar); cdecl;

// typedef int (*GET_DATE_AND_TIME) (BYTE *tm);
  {$EXTERNALSYM GET_DATE_AND_TIME}
  GET_DATE_AND_TIME = function (tm: PByte): INT_16; cdecl;

// typedef INT_32 (*VERIFY_PASSWORD) (char *username, char *host,
//    char *password, INT_32 select);
  {$EXTERNALSYM VERIFY_PASSWORD}
  VERIFY_PASSWORD = function(UserName, Host, Password: PAnsiChar; Select: INT_32): INT_32; cdecl;

// typedef int (*WRITE_PROFILE) (char *section, char *fname);
  {$EXTERNALSYM WRITE_PROFILE}
  WRITE_PROFILE = function(Section, FName: PAnsiChar): INT_16; cdecl;

// typedef int (*MODULE_STATE) (char *modname, int set_value, int state);
  {$EXTERNALSYM MODULE_STATE}
  MODULE_STATE = function (ModName: PAnsiChar; Set_Value, State: INT_16): INT_16; cdecl;

//  Job control functions
// typedef void * (*JI_SCAN_FIRST_JOB) (int type, int mode, void **data);
  {$EXTERNALSYM JI_SCAN_FIRST_JOB}
  JI_SCAN_FIRST_JOB = function(AType, Mode: INT_16; Data: PPointer): Pointer; cdecl;

// typedef void * (*JI_SCAN_NEXT_JOB) (void **data);
  {$EXTERNALSYM JI_SCAN_NEXT_JOB}
  JI_SCAN_NEXT_JOB = function(Data: PPointer): Pointer; cdecl;

// typedef void (*JI_END_SCAN) (void **data);
  {$EXTERNALSYM JI_END_SCAN}
  JI_END_SCAN = function(Data: PPointer): Pointer; cdecl;

// typedef int (*JI_OPEN_JOB) (void *jobhandle);
  {$EXTERNALSYM JI_OPEN_JOB}
  JI_OPEN_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_CLOSE_JOB) (void *jobhandle);
  {$EXTERNALSYM JI_CLOSE_JOB}
  JI_CLOSE_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef void (*JI_REWIND_JOB) (void *jobhandle, int flags);
  {$EXTERNALSYM JI_REWIND_JOB}
  JI_REWIND_JOB = function(JobHandle: Pointer; Flags: INT_16): INT_16; cdecl;

// typedef int (*JI_DISPOSE_JOB) (void *jobhandle);
  {$EXTERNALSYM JI_DISPOSE_JOB}
  JI_DISPOSE_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_PROCESS_JOB) (void *jobhandle);
  {$EXTERNALSYM JI_PROCESS_JOB}
  JI_PROCESS_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_DELETE_JOB) (void *jobhandle);
  {$EXTERNALSYM JI_DELETE_JOB}
  JI_DELETE_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_ABORT_JOB) (void *jobhandle, int fatal);
  {$EXTERNALSYM JI_ABORT_JOB}
  JI_ABORT_JOB = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_GET_JOB_INFO) (void *jobhandle, JOBINFO *ji);
  {$EXTERNALSYM JI_GET_JOB_INFO}
  JI_GET_JOB_INFO = function(JobHandle: Pointer; JobInfo: PJobinfo): INT_16; cdecl;

// typedef int (*JI_GET_JOB_STATE) (void *job, int *jtype, int *jstatus);
  {$EXTERNALSYM JI_GET_JOB_STATE}
  JI_GET_JOB_STATE = function(Job: PPointer; JType: PInt16; JStatus: PInt16): INT_16; cdecl;

// typedef void * (*JI_CREATE_JOB) (int type, char *from,
//   unsigned char *start_time);
  {$EXTERNALSYM JI_CREATE_JOB}
  JI_CREATE_JOB = function(AType: INT_16; From: PAnsiChar; StartTime: PAnsiChar): Pointer; cdecl;

// typedef int (*JI_ADD_ELEMENT) (void *jobhandle, char *address);
  {$EXTERNALSYM JI_ADD_ELEMENT}
  JI_ADD_ELEMENT = function(JobHandle: Pointer; Address: PAnsiChar): INT_16; cdecl;

// typedef int (*JI_ADD_DATA) (void *jobhandle, char *data);
  {$EXTERNALSYM JI_ADD_DATA}
  JI_ADD_DATA = function(JobHandle: Pointer; Data: PAnsiChar): INT_16; cdecl;

// typedef char * (*JI_GET_DATA) (void *jobhandle, char *buffer, int buflen);
  {$EXTERNALSYM JI_GET_DATA}
  JI_GET_DATA = function(JobHandle: Pointer; Buffer: PAnsiChar; BufLen: INT_16): PAnsiChar; cdecl;

// typedef char * (*JI_GET_NEXT_ELEMENT) (void *jobhandle, int type, JOBINFO *job);
  {$EXTERNALSYM JI_GET_NEXT_ELEMENT}
  JI_GET_NEXT_ELEMENT = function(JobHandle: Pointer; AType: INT_16; Job: PJobinfo): PAnsiChar; cdecl;

// typedef int (*JI_SET_JOB_FLAGS) (void *jobhandle, long flags);
  {$EXTERNALSYM JI_SET_JOB_FLAGS}
  JI_SET_JOB_FLAGS = function(JobHandle: Pointer; Flags: LONG): INT_16; cdecl;

//typedef int (*JI_SET_ELEMENT_STATUS) (void *jobhandle, int mode,
//   unsigned char *date);
  {$EXTERNALSYM JI_SET_ELEMENT_STATUS}
  JI_SET_ELEMENT_STATUS = function(JobHandle: Pointer; mode: INT_16; Date: PAnsiChar): INT_16; cdecl;

// typedef int (*JI_SET_ELEMENT_RESOLVINFO) (void *jobhandle, char *ip1, char *ip2,
//   char *ip3, char *ip4);
  {$EXTERNALSYM JI_SET_ELEMENT_RESOLVINFO}
  JI_SET_ELEMENT_RESOLVINFO = function(JobHandle: Pointer; ip1, ip2, ip3, ip4: PAnsiChar): INT_16; cdecl;

// typedef int (*JI_SET_DIAGNOSTICS) (void *jobhandle, int forwhat, char *text);
  {$EXTERNALSYM JI_SET_DIAGNOSTICS}
  JI_SET_DIAGNOSTICS = function(JobHandle: Pointer; ForWhat: INT_16; Text: PAnsiChar): INT_16; cdecl;

// typedef int (*JI_GET_DIAGNOSTICS) (void *jobhandle, int forwhat, char *fname);
  {$EXTERNALSYM JI_GET_DIAGNOSTICS}
  JI_GET_DIAGNOSTICS = function(JobHandle: Pointer; ForWhat: INT_16; FName: PAnsiChar): INT_16; cdecl;

// typedef void (*JI_INCREMENT_TIME) (unsigned char *tm, unsigned int secs);
  {$EXTERNALSYM JI_INCREMENT_TIME}
  JI_INCREMENT_TIME = procedure(tm: PAnsiChar; Secs: UINT_16); cdecl;

// typedef long (*JI_TELL) (void *jobhandle, int selector);
  {$EXTERNALSYM JI_TELL}
  JI_TELL = function(JobHandle: Pointer; Selector: INT_16): LONG; cdecl;

// typedef int (*JI_SEEK) (void *jobhandle, long ofs, int selector);
  {$EXTERNALSYM JI_SEEK}
  JI_SEEK = function(JobHandle: Pointer; Ofs: LONG; Selector: INT_16): LONG; cdecl;

// typedef void * (*JI_GET_JOB_BY_ID) (char *id);
  {$EXTERNALSYM JI_GET_JOB_BY_ID}
  JI_GET_JOB_BY_ID = function(ID: PAnsiChar): Pointer; cdecl;

// typedef int (*JI_GET_JOB_TIMES) (void *job, char *submitted, char *ready);
  {$EXTERNALSYM JI_GET_JOB_TIMES}
  JI_GET_JOB_TIMES = function(Job: Pointer; Ready, Submitted: PAnsiChar): INT_16; cdecl;

//  30 May 2005: New for v4.10
// typedef int (*JI_ACCESS_JOB_DATA) (void *jobhandle, char *data_fname, int len);
  {$EXTERNALSYM JI_ACCESS_JOB_DATA}
  JI_ACCESS_JOB_DATA = function(JobHandle: Pointer; DataFName: PAnsiChar; Len: INT_16): INT_16; cdecl;

// typedef int (*JI_UNACCESS_JOB_DATA) (void *jobhandle);
  {$EXTERNALSYM JI_UNACCESS_JOB_DATA}
  JI_UNACCESS_JOB_DATA = function(JobHandle: Pointer): INT_16; cdecl;

// typedef int (*JI_UPDATE_JOB_DATA) (void *jobhandle, char *dfname);
  {$EXTERNALSYM JI_UPDATE_JOB_DATA}
  JI_UPDATE_JOB_DATA = function(JobHandle: Pointer; DFName: PAnsiChar): INT_16; cdecl;

// typedef void (*JI_ACQUIRE_QUEUE) (int which);
  {$EXTERNALSYM JI_ACQUIRE_QUEUE}
  JI_ACQUIRE_QUEUE = function(Which: INT_16): INT_16; cdecl;

// typedef void (*JI_RELINQUISH_QUEUE) (int which);
  {$EXTERNALSYM JI_RELINQUISH_QUEUE}
  JI_RELINQUISH_QUEUE = function(Which: INT_16): INT_16; cdecl;

//  MNICA functions
// typedef int (*GET_FIRST_GROUP_MEMBER) (char *group, char *host, char *member,
//   int mlen, void **data);
   {$EXTERNALSYM GET_FIRST_GROUP_MEMBER}
   GET_FIRST_GROUP_MEMBER = function(Group, Host, Member: PAnsiChar;
     mLen: INT_16; Data: PPointer): INT_16; cdecl;

// typedef int (*GET_NEXT_GROUP_MEMBER) (char *member, int mlen, void **data);
   {$EXTERNALSYM GET_NEXT_GROUP_MEMBER}
   GET_NEXT_GROUP_MEMBER = function(Member: PAnsiChar; mLen: INT_16; Data: PPointer): INT_16; cdecl;

// typedef int (*END_GROUP_SCAN) (void **data);
   {$EXTERNALSYM END_GROUP_SCAN}
   END_GROUP_SCAN = function(Data: PPointer): INT_16; cdecl;

// typedef int (*IS_VALID_LOCAL_USER) (char *address, char *username, char *host);
   {$EXTERNALSYM IS_VALID_LOCAL_USER}
   IS_VALID_LOCAL_USER = function(Address, UserName, Host: PAnsiChar): INT_16; cdecl;

// typedef int (*IS_GROUP_MEMBER) (char *host, char *username, char *groupname);
   {$EXTERNALSYM IS_GROUP_MEMBER}
   IS_GROUP_MEMBER = function(Host, UserName, GroupName: PAnsiChar): INT_16; cdecl;

// typedef int (*GET_FIRST_USER_DETAILS) (char *host, char *match, char *username,
//    int ulen, char *address, int alen, char *fullname, int flen, void **data);
   {$EXTERNALSYM GET_FIRST_USER_DETAILS}
   GET_FIRST_USER_DETAILS = function(Host, Match, UserName: PAnsiChar; ULen: INT_16;
     Address: PAnsiChar; ALen: INT_16; FullName: PAnsiChar; FLen: INT_16;
     Data: PPointer): INT_16; cdecl;

// typedef int (*GET_NEXT_USER_DETAILS) (char *username, int ulen, char *address,
//    int alen, char *fullname, int flen, void **data);
   {$EXTERNALSYM GET_NEXT_USER_DETAILS}
   GET_NEXT_USER_DETAILS = function(Host: PAnsiChar; ULen: INT_16;
     Address: PAnsiChar; ALen: INT_16; FullName: PAnsiChar; FLen: INT_16;
     Data: PPointer): INT_16; cdecl;

// typedef int (*GET_USER_DETAILS) (char *host, char *match, char *username, int ulen,
//    char *address, int alen, char *fullname, int flen);
   {$EXTERNALSYM GET_USER_DETAILS}
   GET_USER_DETAILS = function(Host, Match, UserName: PAnsiChar; ULen: INT_16;
     Address: PAnsiChar; ALen: INT_16; FullName: PAnsiChar; FLen: INT_16): INT_16; cdecl;

// typedef int (*END_USER_SCAN) (void **data);
   {$EXTERNALSYM END_USER_SCAN}
   END_USER_SCAN = function(Data: PPointer): INT_16; cdecl;

// typedef void (*READ_PMPROP) (char *userid, char *server, PMPROP *p);
   {$EXTERNALSYM READ_PMPROP}
   READ_PMPROP = function(UserID, Server: PAnsiChar; P: PPmprop): INT_16; cdecl;

// typedef int (*CHANGE_OWNERSHIP) (char *fname, char *host, char *newowner);
   {$EXTERNALSYM CHANGE_OWNERSHIP}
   CHANGE_OWNERSHIP = function(FName, Host, NewOwner: PAnsiChar): INT_16; cdecl;

// typedef int (*BEGIN_SINGLE_DELIVERY) (char *uic, char *server, void **data);
   {$EXTERNALSYM BEGIN_SINGLE_DELIVERY}
   BEGIN_SINGLE_DELIVERY = function(UIC, Server: PAnsiChar; Data: PPointer): INT_16; cdecl;

// typedef void (*END_SINGLE_DELIVERY) (void **data);
   {$EXTERNALSYM END_SINGLE_DELIVERY}
   END_SINGLE_DELIVERY = procedure(Data: PPointer); cdecl;

// typedef INT_32 (*IS_NETWORK_READY) (INT_32 quick);
   {$EXTERNALSYM IS_NETWORK_READY}
   IS_NETWORK_READY = function(Quick: INT_32): INT_16; cdecl;

//  Miscellaneous functions - Mercury 2.11 and later only
// typedef UINTP (*MERCURY_COMMAND) (DWORD selector, UINTP parm1, UINTP parm2);
   {$EXTERNALSYM MERCURY_COMMAND}
   MERCURY_COMMAND = function(Selector: DWORD; Param1, Parm2: UINTP): UINTP; cdecl;

// typedef char * (*GET_DATE_STRING) (int dtype, char *buf, BYTE *date);
   {$EXTERNALSYM GET_DATE_STRING}
   GET_DATE_STRING = function(DType: INT_16; Buf: PAnsiChar; Date: PByte): PAnsiChar; cdecl;

// typedef char * (*RFC822_TIME) (char *buffer);
   {$EXTERNALSYM RFC822_TIME}
   RFC822_TIME = function(Buffer: PAnsiChar): INT_16; cdecl;

// typedef char * (*RFC821_TIME) (char *buffer);
   {$EXTERNALSYM RFC821_TIME}
   RFC821_TIME = function(Buffer: PAnsiChar): INT_16; cdecl;

//  File I/O and parsing functions - Mercury 2.15 and later only
// typedef INT_32 (*FM_OPEN_FILE) (char *path, UINT_32 flags);
{$EXTERNALSYM FM_OPEN_FILE}
   FM_OPEN_FILE = function(Path: PAnsiChar; Flags: UINT_32): INT_32; cdecl;

// typedef INT_32 (*FM_OPEN_MESSAGE) (IMESSAGE *im, UINT_32 flags);
{$EXTERNALSYM FM_OPEN_MESSAGE}
   FM_OPEN_MESSAGE = function(IMessage: Pointer; Flags: UINT_32): INT_32; cdecl;

// typedef int (*FM_CLOSE_MESSAGE) (INT_32 id);
{$EXTERNALSYM FM_CLOSE_MESSAGE}
   FM_CLOSE_MESSAGE = function (ID: INT_32): INT_16; cdecl;

// typedef char * (*FM_GETS) (char *buf, INT_32 max, INT_32 id);
{$EXTERNALSYM FM_GETS}
   FM_GETS = function(Buf: PAnsiChar; Max, ID: INT_32): PAnsiChar; cdecl;

// typedef INT_16 (*FM_GETC) (INT_32 id);
{$EXTERNALSYM FM_GETC}
   FM_GETC = function(ID: INT_32): INT_16; cdecl;

// typedef void (*FM_UNGETC) (INT_16 c, INT_32 id);
{$EXTERNALSYM FM_UNGETC}
   FM_UNGETC = function(c: INT_32; ID: INT_32): INT_16; cdecl;

// typedef INT_32 (*FM_READ) (INT_32 id, char *buffer, INT_32 bufsize);
{$EXTERNALSYM FM_READ}
   FM_READ = function(ID: INT_32; Buffer: PAnsiChar; BufSize: INT_32): INT_32; cdecl;

// typedef INT_32 (*FM_GETPOS) (INT_32 fil);
{$EXTERNALSYM FM_GETPOS}
   FM_GETPOS = function(fil: INT_32): INT_32; cdecl;

// typedef INT_16 (*FM_SETPOS) (INT_32 fil, INT_32 offset);
{$EXTERNALSYM FM_SETPOS}
   FM_SETPOS = function(fil, offset: INT_32): INT_16; cdecl;

// typedef INT_32 (*FM_GET_FOLDED_LINE) (INT_32 fil, char *line, int limit);
{$EXTERNALSYM FM_GET_FOLDED_LINE}
   FM_GET_FOLDED_LINE = function(fil: INT_32; Line: PAnsiChar; Limit: INT_16): INT_32; cdecl;

// typedef char * (*FM_FIND_HEADER) (INT_32 fil, char *name, char *buf, int len);
{$EXTERNALSYM FM_FIND_HEADER}
   FM_FIND_HEADER = function(fil: INT_32; Name, Buf: PAnsiChar; Len: INT_16): INT_32; cdecl;

// typedef int (*FM_EXTRACT_MESSAGE) (void *job, char *fname, int flags);
{$EXTERNALSYM FM_EXTRACT_MESSAGE}
   FM_EXTRACT_MESSAGE = function(Job: Pointer; FName: PAnsiChar; Flags: INT_16): INT_32; cdecl;

// typedef int (*PARSE_HEADER) (INT_32 fil, IMESSAGE *m);
{$EXTERNALSYM PARSE_HEADER}
   PARSE_HEADER = function(fil: INT_32; m: PIMessage): INT_16; cdecl;

// typedef int (*MIME_PREP_MESSAGE) (INT_32 fil, char *fname, int headers);
{$EXTERNALSYM MIME_PREP_MESSAGE}
   MIME_PREP_MESSAGE = function(fir: INT_32; FName: PAnsiChar; Headers: INT_16): INT_32; cdecl;


// #ifdef M_NO_MIME
// typedef int (*_PARSE_MIME) (INT_32 fil, void *m);
{$EXTERNALSYM _PARSE_MIME1}
  _PARSE_MIME1 = function(fil: INT_32; m: Pointer): INT_16 cdecl;

// typedef void (*FREE_MIME) (void *m);
{$EXTERNALSYM FREE_MIME1}
  FREE_MIME1 = procedure(M: Pointer); cdecl;

// typedef int (*FAKE_IMESSAGE) (IMESSAGE *im, char *dest, char *src,
//   void *m, char *boundary);
{$EXTERNALSYM FAKE_IMESSAGE}
  FAKE_IMESSAGE = function (im: PIMessage; Dest, Src: PAnsiChar; m: Pointer;
    Boundary: PAnsiChar): INT_16; cdecl;

// #else
// typedef int (*_PARSE_MIME) (INT_32 fil, IMIME *m);
{$EXTERNALSYM _PARSE_MIME2}
  _PARSE_MIME2 = function(fil: INT_32; m: PImime): INT_16; cdecl;

// typedef void (*FREE_MIME) (IMIME *m);
{$EXTERNALSYM FREE_MIME2}
  FREE_MIME2 = procedure(m: PImime); cdecl;

// typedef int (*FAKE_IMESSAGE) (IMESSAGE *im, char *dest, char *src,
//   IMIME *m, char *boundary);
{$EXTERNALSYM FAKE_IMESSAGE2}
  FAKE_IMESSAGE2 = function(im: PIMESSAGE; Dest, Src: PAnsiChar; m: PImime;
    Boundary: PAnsiChar): INT_16; cdecl;
// #endif
// *)

//typedef int (*DECODE_MIME_HEADER) (char *dest, char *src);
{$EXTERNALSYM DECODE_MIME_HEADER}
  DECODE_MIME_HEADER = function(Dest, Src: PAnsiChar): INT_16; cdecl;

//typedef int (*ENCODE_MIME_HEADER) (char *dest, char *src, int raw);
{$EXTERNALSYM ENCODE_MIME_HEADER}
  ENCODE_MIME_HEADER = function(Dest, Src: PAnsiChar; Raw: INT_16): INT_16; cdecl;

//typedef int (*DECODE_MIME_HEADER_EX) (char *dest, int dlen, char *src, unsigned long flags);
{$EXTERNALSYM DECODE_MIME_HEADER_EX}
  DECODE_MIME_HEADER_EX = function(Dest: PAnsiChar; DLen: INT_16;
    Src: PAnsiChar; Flags: ULONG): INT_16; cdecl;

//typedef int (*ENCODE_BASE64_FILE) (char *infname, char *outfname, char *boundary);
{$EXTERNALSYM ENCODE_BASE64_FILE}
  ENCODE_BASE64_FILE = function(InFName, OutFName, Boundary: PAnsiChar): INT_16; cdecl;

//typedef int (*DECODE_BASE64_FILE) (char *infname, char *outfname, char *boundary);
{$EXTERNALSYM DECODE_BASE64_FILE}
  DECODE_BASE64_FILE = function(InFName, OutFName, Boundary: PAnsiChar): INT_16; cdecl;

//typedef void * (*OM_CREATE_MESSAGE) (UINT_32 mtype, UINT_32 flags);
{$EXTERNALSYM OM_CREATE_MESSAGE}
  OM_CREATE_MESSAGE = function(m_type, flags: UINT_32): Pointer; cdecl;

//typedef INT_32 (*OM_DISPOSE_MESSAGE) (void *mhandle);
{$EXTERNALSYM OM_DISPOSE_MESSAGE}
  OM_DISPOSE_MESSAGE = function(mhandle: PPointer): UINT_32; cdecl;

//typedef INT_32 (*OM_ADD_FIELD) (void *mhandle, UINT_32 selector, char *data);
{$EXTERNALSYM OM_ADD_FIELD}
  OM_ADD_FIELD = function(m_type: Pointer; Selector: UINT_32; Data: PAnsiChar): UINT_32; cdecl;

//typedef INT_32 (*OM_ADD_ATTACHMENT) (void *mhandle, char *fname, char *ftype,
//   char *description, UINT_32 encoding, UINT_32 flags, void *reserved);
{$EXTERNALSYM OM_ADD_ATTACHMENT}
  OM_ADD_ATTACHMENT = function(mhandle: Pointer; FName, FType,
    Description: PAnsiChar; Encoding, Flags: UINT_32; Reserved: Pointer): UINT_32; cdecl;

//typedef INT_32 (*OM_WRITE_MESSAGE) (void *mhandle, char *fname);
{$EXTERNALSYM OM_WRITE_MESSAGE}
  OM_WRITE_MESSAGE = function(mHandle: Pointer; FName: PAnsiChar): UINT_32; cdecl;

//typedef void * (*OM_SEND_MESSAGE) (void *mhandle, char *envelope);
{$EXTERNALSYM OM_SEND_MESSAGE}
  OM_SEND_MESSAGE = function(mHandle: Pointer; FName: PAnsiChar): Pointer; cdecl;

//typedef int (*ENCODE_BASE64_STR) (char *dest, char *src, int srclen);
{$EXTERNALSYM ENCODE_BASE64_STR}
  ENCODE_BASE64_STR = function(Dest, Src: PAnsiChar; SrcLen: INT_16): INT_16; cdecl;

//typedef int (*DECODE_BASE64_STR) (char *dest, char *src, char *table);
{$EXTERNALSYM DECODE_BASE64_STR}
  DECODE_BASE64_STR = function(Dest, Src, Table: PAnsiChar): INT_16; cdecl;

//typedef INT_32 (*ST_REGISTER_MODULE) (char *module_name);
{$EXTERNALSYM ST_REGISTER_MODULE}
  ST_REGISTER_MODULE = function(ModuleName: PAnsiChar): INT_32; cdecl;

//typedef INT_32 (*ST_UNREGISTER_MODULE) (INT_32 mhandle);
{$EXTERNALSYM ST_UNREGISTER_MODULE}
  ST_UNREGISTER_MODULE = function(Handle: INT_32): INT_32; cdecl;

//typedef INT_32 (*ST_CREATE_CATEGORY) (INT_32 mhandle, char *cname,
//   INT_32 ctag, INT_32 ctype, INT_32 dlen, UINT_32 flags);
{$EXTERNALSYM ST_CREATE_CATEGORY}
  ST_CREATE_CATEGORY = function(Handle: INT_32; CName: PAnsiChar; ctag, ctype,
    dlen: INT_32; Flags: UINT_32): INT_32; cdecl;

//typedef INT_32 (*ST_REMOVE_CATEGORY) (INT_32 mhandle, UINT_32 ctag);
{$EXTERNALSYM ST_REMOVE_CATEGORY}
  ST_REMOVE_CATEGORY = function(Handle: INT_32; ctag: UINT_32): INT_32; cdecl;

//typedef INT_32 (*ST_SET_HCATEGORY) (INT_32 chandle, UINT_32 data);
{$EXTERNALSYM ST_SET_HCATEGORY}
  ST_SET_HCATEGORY = function(CHandle: INT_32; Data: UINT_32): INT_32; cdecl;

//typedef INT_32 (*ST_SET_CATEGORY) (INT_32 mhandle, INT_32 ctag, UINT_32 data);
{$EXTERNALSYM ST_SET_CATEGORY}
  ST_SET_CATEGORY = function(Handle, ctag: INT_32; Data: UINT_32): INT_32; cdecl;

//void LOGSTRING (INT_16 ltype, INT_16 priority, char *str);
  LOGSTRING = procedure (ltype, priority: INT_16; str: PAnsiChar); cdecl;

//void LOGDATA (INT_16 ltype, INT_16 priority, char *fmt, ...);
  LOGDATA = procedure (ltype, priority: INT_16; fmt: PAnsiChar); cdecl varargs;

// typedef INT_32 (*CREATE_OBJECT) (char *objectname, INT_32 objecttype,
//    char *id, INT_32 flags);
  CREATE_OBJECT = function(ObjectName: PChar; ObjectType: INT_32; ID: PAnsiChar;
    Flags: INT_32): INT_32; cdecl;

// typedef INT_32 (*SET_PASSWORD) (char *username, char *host, char *newpassword,
//    char *oldpassword, INT_32 select);
   SET_PASSWORD = function(UserName, Host, NewPassword, OldPassword: PAnsiChar;
     Select: INT_32): INT_32; cdecl;

// typedef INT_32 (*ST_GET_NEXT_MODULE) (INT_32 mhandle, char *modname);
   ST_GET_NEXT_MODULE = function(ModuleHandle: INT_32; ModuleName: PAnsiChar): INT_32; cdecl;

// typedef INT_32 (*ST_GET_NEXT_CATEGORY) (INT_32 mhandle, INT_32 chandle,
//    char *cname, INT_32 *ctype, INT_32 *clen, INT_32 *cflags);
   ST_GET_NEXT_CATEGORY = function(ModuleHandle, CHandle: INT_32; CName: PAnsiChar;
     CType, CLen, CFlags: PUInt32): INT_32; cdecl;

// typedef INT_32 (*ST_GET_CATEGORY_DATA) (INT_32 chandle, void *data);
  ST_GET_CATEGORY_DATA = function(CategoryHandle: INT_32; Data: Pointer): INT_32; cdecl;

// typedef INT_32 (*ST_EXPORT_STATS) (INT_32 mhandle, char *fname, UINT_32 flags);
  ST_EXPORT_STATS = function(ModuleHandle: INT_32; FName: PAnsiChar; Flags: UINT_32): INT_32; cdecl;

// typedef INT_32 (*SELECT_PRINTER) (char *devicename, int maxlen);
  SELECT_PRINTER = function(DeviceName: PAnsiChar; MaxLen: INT_16): INT_32; cdecl;

// typedef INT_32 (* PRINT_FILE) (char *fname, char *printername, UINT_32 flags,
//    INT_32 lrmargin, INT_32 tbmargin, char *title, char *username, char *fontname,
//    INT_32 fontsize);
  PRINT_FILE = function(FName, PrinterName: PAnsiChar; Flags: UINT_32;
    LRMargin, TBMargin: INT_32; Title, UserName, FontName: PAnsiChar;
    FontSize: INT_32) : INT_32; cdecl;

//  Folder management functions - Mercury/32 v3.01b and later

// typedef INT_16 (*FM_COPY_MESSAGE) (IMESSAGE *im, FOLDER *dest);
  FM_COPY_MESSAGE = function (im: PIMessage; Dest: PFolder): INT_16; cdecl;

// typedef INT_16 (*FM_DELETE_MESSAGE) (IMESSAGE *im, UINT_32 flags);
  FM_DELETE_MESSAGE = function(im: PIMessage; Flags: UINT_32): INT_16; cdecl;

// typedef INT_16 (*FM_MOVE_MESSAGE) (IMESSAGE *im, FOLDER *dest);
  FM_MOVE_MESSAGE = function (im: PIMessage; Dest: PFolder): INT_16; cdecl;

// typedef INT_16 (*FM_SAVE_MESSAGE_STATUS) (IMESSAGE *im);
  FM_SAVE_MESSAGE_STATUS = function (im: PIMessage): INT_16; cdecl;

// typedef INT_16 (*FM_SAVE_MESSAGE_READ_STATUS) (IMESSAGE *im, BOOL isread);
  FM_SAVE_MESSAGE_READ_STATUS = function (im: PIMessage; IsRead: BOOL): INT_16; cdecl;

// typedef INT_16 (*FM_SAVE_MESSAGE_FIELDS) (IMESSAGE *im);
  FM_SAVE_MESSAGE_FIELDS = function (im: PIMessage): INT_16; cdecl;

// typedef INT_16 (*FM_RELEASE_MESSAGE) (IMESSAGE *im);
  FM_RELEASE_MESSAGE = function (im: PIMessage): INT_16; cdecl;


//  In FOL_MSG.C
// typedef char * (*FM_FIND_MESSAGE_HEADER) (IMESSAGE *im, char *name, char *buf, int len);
  FM_FIND_MESSAGE_HEADER = function (im: PIMessage; Name, Buf: PAnsiChar; Len: INT_16): PAnsiChar; cdecl;

// typedef int (*FM_EXTRACT_FILE_MESSAGE) (INT_32 ifil, char *fname, int flags);
  FM_EXTRACT_FILE_MESSAGE = function(IFil: INT_32; FName: PAnsiChar; Flags: INT_16): INT_16; cdecl;

// typedef int (*FM_EXTRACT_MSG_MESSAGE) (IMESSAGE *im, char *fname, int flags);
  FM_EXTRACT_MSG_MESSAGE = function(im: PIMessage; FName: PChar; Flags: INT_16): INT_16; cdecl;

// typedef INT_16 (*FM_IS_NEWMAIL) (INT_32 message);
  FM_IS_NEWMAIL = function(Message: UINT_32): INT_16; cdecl;

//  In FOL_FLDR.C
// typedef FOLDER * (*FM_CREATE_FOLDER) (void *cdata, char *module_name, char *vname);

// typedef FOLDER * (*FM_CREATE_FOLDER_EX) (void *cdata, char *module_name, char *vname,
//   INT_32 flags, INT_16 mailbox_id);

// typedef INT_16 (*FM_OPEN_FOLDER) (FOLDER *folder, HWND hWnd, UINT_32 flags);

// typedef INT_16 (*FM_CLOSE_FOLDER) (FOLDER *folder);

// typedef INT_16 (*FM_DELETE_FOLDER) (FOLDER *folder);

// typedef INT_16 (*FM_RENAME_FOLDER) (FOLDER *folder, char *newname);

// typedef FOLDER * (*FM_FIND_FOLDER) (void *cdata, char *unique_id, char *vname, int vlen);

// typedef FOLDER * (*FM_FIND_FOLDER_BY_NAME) (void *cdata, char *vname);

// typedef FOLDER * (*FM_GET_FOLDER) (void *cdata, UINT_32 *offset, UINT_32 flags, INT_16 mailbox_id);

//  In FOL_MISC.C
// typedef HWND (*FM_GET_FOLDER_WINDOW) (FOLDER *folder, char *name);

// typedef INT_16 (*FM_COPY_FILE_INTO_FOLDER) (FOLDER *dest, char *fname,
//   IMESSAGE *im, UINT_32 flags, UINT_32 mflags);


//  In FOL_INIT.C
// #define FSF_UNIQUE 1

// typedef void * (*FM_STARTUP) (char *username, char *password, UINT_32 flags);

// typedef void (*FM_SHUTDOWN) (void *fcdata, int terminating);

// typedef INT_32 (*FM_RESYNCH_NEWMAILBOX) (void *cdata, INT_16 is_timer, INT_16 sync_limit);

// typedef INT_16 (*FM_MOUNT_MAILBOX) (void *fcdata, char *path, char *name, UINT_32 flags);

// typedef INT_16 (*FM_UNMOUNT_MAILBOX) (void *fcdata, INT_16 mailbox_id);

// typedef DWORD (*FM_SEND_MESSAGE) (FOLDER *folder, UINT wMsg, UINT_32 parm1, UINT_32 parm2);

// typedef UINT_32 (*FM_GET_MESSAGE_CAPS) (IMESSAGE *im);

// typedef INT_16 (*FM_GET_MAILBOX_UID) (void *fcdata, INT_16 mbx_id, char *unique_id);

// typedef INT_32 (*FM_GET_INSTANCES) (void *fcdata, FOLDER *folder);

// typedef INT_32 (*FM_LOCK) (void *fcdata);

// typedef INT_32 (*FM_UNLOCK) (void *fcdata);


//  In FPL_FILE.C
// typedef INT_16 (*FM_ASSOCIATE_FILE) (IMESSAGE *im, char *fname, UINT_32 flags);

// typedef INT_16 (*FM_DISSOCIATE_FILE) (IMESSAGE *im);

//  In FOL_CODE.C - support for uuencoding and binhex
// typedef int (*UUDECODE) (int in, FILE *out);

// typedef void (*UUENCODE) (FILE *fil, char *fname);

// typedef void (*CALC_CRC) (INT_16 *crc, int val);

// typedef int (*GET_FILESIZE) (char *name, long *datasize, long *resourcesize);

// typedef int (*FBINHEX) (FILE *dest, char *sourcename);

// typedef int (*UNBINHEX_FILE) (INT_32 fil, FILE *dest);

// typedef int (*UNBINHEX) (INT_32 fil, char *dest, int name_only);

// typedef int (*BINHEX_INFO) (INT_32 fil, char *fname, long *dlength, long *rlength);

// void CALC_CRC (INT_16 *crc, int val);
{$EXTERNALSYM CALC_CRC}
  CALC_CRC = procedure (var crc: INT_16; val: Integer); cdecl;

//  In FOLMAN.C

// typedef INT_16 (*FMM_UPDATE_HIERARCHY_ENTRY) (void *fcdata, UINT_32 flags, FOLDER *folder);

// typedef INT_16 (*FMM_GET_ENTRY_MAILBOX) (void *fcdata, char *unique_id);

// typedef void (*FMM_INITIALIZE_FOLMAN) (void *fcdata);

// typedef void (*FMM_SHUTDOWN_FOLMAN) (void *fcdata);

// typedef int (*FMM_GET_OBJECT) (void *fcdata, int mbx, int offset, FMM_ENTRY *fme);

// typedef int (*FMM_GET_OBJECT_BY_ID) (void *fcdata, char *id, FMM_ENTRY *fme);

// typedef int (*FMM_CREATE_OBJECT) (void *fcdata, int otype, char *name,
//   char *flags, char *parent_id, FMM_ENTRY *new_fme);

// typedef int (*FMM_DELETE_OBJECT) (void *fcdata, char *id);

// typedef int (*FMM_SET_PARENT) (void *fcdata, char *item_id, char *parent_id);

// typedef int (*FMM_RENAME_OBJECT) (void *fcdata, char *item_id, char *newname);

//  In FOL_ATT.C  - Attachment management

// typedef int (*SCAN_ENCLOSURES) (INT_32 fil, LIST *list);

// typedef int (*GET_ATTACHMENT_LIST) (IMESSAGE *im, LIST *list);

// typedef int (*GET_ATTACHMENTS_FROM_FILE) (char *fname, LIST *list);

// typedef void (*PROCESS_FILENAME_STRING) (char *dest, char *src);

// typedef int (*MAKE_FILE_FROM_TEMPLATE) (char *tplname, char *outname,
//   char *resultname, void *mjob, char *parms [10]);


//  In DLIST.C
// typedef void * (*DL_OPEN_MEMBERSHIP) (DLIST *d, int readonly);

// typedef void (*DL_CLOSE_MEMBERSHIP) (void *data);

// typedef INT_32 (*DL_GETPOS) (void *data);

// typedef int (*DL_SETPOS) (void *data, INT_32 pos);

// typedef int (*DL_GET_NEXT_SUBSCRIBER) (void *data, SUBSCRIBER *subs, UINT_32 flags);

// typedef int (*DL_FIND_SUBSCRIBER) (void *data, SUBSCRIBER *subs, char *address);

// typedef int (*DL_VERIFY_LIST_PASSWORD) (DLIST *d, int selector, char *candidate);

// typedef int (*DL_AUTOGENERATE_PASSWORD) (char *pwd, int len, UINT_32 flags);

// typedef int (*DL_ADD_SUBSCRIBER) (void *data, SUBSCRIBER *subs);

// typedef int (*DL_UPDATE_SUBSCRIBER) (void *data, SUBSCRIBER *subs);

// typedef int (*DL_REMOVE_SUBSCRIBER) (void *data, char *address);

// typedef int (*DL_SEND_SUBSCRIPTION_MESSAGE) (DLIST *d, SUBSCRIBER *subs, int unsub);

// typedef int (*DL_SEND_SUBSCRIPTION_CONFIRMATION) (DLIST *d, char *address, char *name, char *pwd);

// typedef int (*DL_COMPLETE_SUBSCRIPTION_CONFIRMATION) (DLIST *d, SUBSCRIBER *subs, char *id);

// typedef void (*DL_ACCESS) (int mode);

//  New in v4.1 - you must call "dlist_acquire_list" before attempting
//  to manipulate a list in any way; you must call dlist_release_list
//  exactly once when you have finished (you can acquire the list as
//  often as you wish from within the same thread, but you must release
//  it only once.

// typedef int (*DLIST_ACQUIRE_LIST) (char *lname, int waitsecs);
{$EXTERNALSYM DLIST_ACQUIRE_LIST}
   DLIST_ACQUIRE_LIST = function(ListName: PAnsiChar; WaitSecs: INT_16): INT_16; cdecl;

// typedef int (*DLIST_RELEASE_LIST) (char *lname);
{$EXTERNALSYM DLIST_RELEASE_LIST}
   DLIST_RELEASE_LIST = function (ListName: PAnsiChar): INT_16; cdecl;

//  In SPAMBUST.C
// typedef int (*EDIT_MESSAGE_HEADERS) (char *fname, char **additions, char **deletions);


//  In DISCLAIM.C - text (disclaimer) insertion into messages
// #define DCRF_TOP 1
// typedef int (*DCR_ADD_TEXT_SECTION) (char *destfname, char *sourcefname,
//   char *textfname, char *htmlfname, UINT_32 flags);

const
//  Event Registration functions - Mercury/32 v4.1 and later

//  Module identifiers reserved by Mercury
  {$EXTERNALSYM MMI_CORE}
  MMI_CORE                            = 1; 
  {$EXTERNALSYM MMI_JOBMANAGER}
  MMI_JOBMANAGER                      = 2; 
  {$EXTERNALSYM MMI_MERCURYS}
  MMI_MERCURYS                        = 20; 
  {$EXTERNALSYM MMI_MERCURYE}
  MMI_MERCURYE                        = 30; 
  {$EXTERNALSYM MMI_MERCURYP}
  MMI_MERCURYP                        = 40;
  {$EXTERNALSYM MMI_MERCURYC}
  MMI_MERCURYC                        = 50; 
  {$EXTERNALSYM MMI_MERCURYD}
  MMI_MERCURYD                        = 60; 
  {$EXTERNALSYM MMI_MERCURYI}
  MMI_MERCURYI                        = 70; 
  {$EXTERNALSYM MMI_MERCURYH}
  MMI_MERCURYH                        = 80;
  {$EXTERNALSYM MMI_MERCURYW}
  MMI_MERCURYW                        = 90; 

type

////typedef struct
////   {
////   char inbuf [1024];
////   char outbuf [1024];
////   } EVENTBUF;

  PEventbuf = ^TEventbuf;
  {$EXTERNALSYM EVENTBUF}
  EVENTBUF = packed record
    inbuf: array[0..1023] of AnsiChar;
    outbuf: array[0..1023] of AnsiChar;
  end;
  TEventbuf = EVENTBUF;

////INT_32 EVENTPROC (UINT_32 module, UINT_32 event, void *edata, void *cdata);

{$EXTERNALSYM EVENTPROC}
  EVENTPROC = function (module: UINT_32; event: UINT_32; edata: Pointer; cdata: Pointer): INT_32; cdecl;

////INT_32 REGISTER_EVENT_HANDLER (UINT_32 module, UINT_32 event, EVENTPROC eproc, void *cdata);

{$EXTERNALSYM REGISTER_EVENT_HANDLER}
  REGISTER_EVENT_HANDLER = function (module: UINT_32; event: UINT_32; eproc: EVENTPROC; cdata: Pointer): INT_32; cdecl;

////INT_32 DEREGISTER_EVENT_HANDLER (UINT_32 module, UINT_32 event, EVENTPROC eproc);

{$EXTERNALSYM DEREGISTER_EVENT_HANDLER}
  DEREGISTER_EVENT_HANDLER = function (module: UINT_32; event: UINT_32; eproc: EVENTPROC): INT_32; cdecl;

////INT_32 GENERATE_EVENT (UINT_32 module, UINT_32 event, void *edata, int stdresult);

{$EXTERNALSYM GENERATE_EVENT}
  GENERATE_EVENT = function (module: UINT_32; event: UINT_32; edata: Pointer; stdresult: Integer): INT_32; cdecl;

const

//  RFC2822 date and time parsing routines, v4.61 and later
  {$EXTERNALSYM ET_WANT_SEQUENCE}
  ET_WANT_SEQUENCE                    = 1;
  {$EXTERNALSYM ET_WANT_STRING}
  ET_WANT_STRING                      = 2;

type
//typedef long (*EXTRACT_TIME) (char *dstr, BYTE *tm, int flags);
{$EXTERNALSYM EXTRACT_TIME}
  EXTRACT_TIME = function(DStr: PAnsiChar; tm: PByte; Flags: INT_16): LONG; cdecl;

//typedef void (*NORMALIZE_TIME) (BYTE *tm, int offset);
{$EXTERNALSYM NORMALIZE_TIME}
  NORMALIZE_TIME = function(tm: PByte; Offset: INT_16): LONG; cdecl;

//typedef int (*COMPARE_DATES) (BYTE *date1, BYTE *date2);
{$EXTERNALSYM COMPARE_DATES}
  COMPARE_DATES = function(Date1, Date2: PByte): LONG; cdecl;

//typedef char *(*GET_TIMEZONE) (char *buffer);
{$EXTERNALSYM GET_TIMEZONE}
  GET_TIMEZONE = function(Buffer: PAnsiChar): LONG; cdecl;

////typedef struct
////   {
////   long dsize;                              //  Size of this structure
////   char vmajor, vminor;
////   HWND hMDIParent;
////   GET_VARIABLE get_variable;
////   IS_LOCAL_ADDRESS is_local_address;
////   IS_GROUP is_group;
////   PARSE_ADDRESS parse_address;
////   EXTRACT_ONE_ADDRESS extract_one_address;
////   EXTRACT_CQTEXT extract_cqtext;
////   DLIST_INFO dlist_info;
////   SEND_NOTIFICATION send_notification;
////   GET_DELIVERY_PATH get_delivery_path;
////   GET_DATE_AND_TIME get_date_and_time;
////   VERIFY_PASSWORD verify_password;
////   WRITE_PROFILE write_profile;
////   MODULE_STATE module_state;
////
////   //  Job control functions
////
////   JI_SCAN_FIRST_JOB ji_scan_first_job;
////   JI_SCAN_NEXT_JOB ji_scan_next_job;
////   JI_END_SCAN ji_end_scan;
////   JI_OPEN_JOB ji_open_job;
////   JI_CLOSE_JOB ji_close_job;
////   JI_REWIND_JOB ji_rewind_job;
////   JI_DISPOSE_JOB ji_dispose_job;
////   JI_PROCESS_JOB ji_process_job;
////   JI_DELETE_JOB ji_delete_job;
////   JI_ABORT_JOB ji_abort_job;
////   JI_GET_JOB_INFO ji_get_job_info;
////   JI_CREATE_JOB ji_create_job;
////   JI_ADD_ELEMENT ji_add_element;
////   JI_ADD_DATA ji_add_data;
////   JI_GET_DATA ji_get_data;
////   JI_GET_NEXT_ELEMENT ji_get_next_element;
////   JI_SET_ELEMENT_STATUS ji_set_element_status;
////   JI_SET_ELEMENT_RESOLVINFO ji_set_element_resolvinfo;
////   JI_SET_DIAGNOSTICS ji_set_diagnostics;
////   JI_GET_DIAGNOSTICS ji_get_diagnostics;
////   JI_INCREMENT_TIME ji_increment_time;
////
////   //  MNICA (Network interface) functions
////
////   GET_FIRST_GROUP_MEMBER get_first_group_member;
////   GET_NEXT_GROUP_MEMBER get_next_group_member;
////   END_GROUP_SCAN end_group_scan;
////   IS_VALID_LOCAL_USER is_valid_local_user;
////   IS_GROUP_MEMBER is_group_member;
////   GET_FIRST_USER_DETAILS get_first_user_details;
////   GET_NEXT_USER_DETAILS get_next_user_details;
////   GET_USER_DETAILS get_user_details;
////   END_USER_SCAN end_user_scan;
////   READ_PMPROP read_pmprop;
////   CHANGE_OWNERSHIP change_ownership;
////   BEGIN_SINGLE_DELIVERY begin_single_delivery;
////   END_SINGLE_DELIVERY end_single_delivery;
////
////   //  Miscellaneous functions
////
////   MERCURY_COMMAND mercury_command;
////   GET_DATE_STRING get_date_string;
////   RFC822_TIME rfc822_time;
////   RFC821_TIME rfc821_time;
////
////   //  File parsing and I/O functions
////
////   FM_OPEN_FILE fm_open_file;
////   FM_OPEN_MESSAGE fm_open_message;
////   FM_CLOSE_MESSAGE fm_close_message;
////   FM_GETS fm_gets;
////   FM_GETC fm_getc;
////   FM_UNGETC fm_ungetc;
////   FM_READ fm_read;
////   FM_GETPOS fm_getpos;
////   FM_SETPOS fm_setpos;
////   FM_GET_FOLDED_LINE fm_get_folded_line;
////   FM_FIND_HEADER fm_find_header;
////   FM_EXTRACT_MESSAGE fm_extract_message;
////
////   PARSE_HEADER parse_header;
////   MIME_PREP_MESSAGE mime_prep_message;
////   _PARSE_MIME parse_mime;
////   FREE_MIME free_mime;
////   FAKE_IMESSAGE fake_imessage;
////   DECODE_MIME_HEADER decode_mime_header;
////   ENCODE_MIME_HEADER encode_mime_header;
////
////   OM_CREATE_MESSAGE om_create_message;
////   OM_DISPOSE_MESSAGE om_dispose_message;
////   OM_ADD_FIELD om_add_field;
////   OM_ADD_ATTACHMENT om_add_attachment;
////   OM_WRITE_MESSAGE om_write_message;
////   OM_SEND_MESSAGE om_send_message;
////
////   ENCODE_BASE64_STR encode_base64_str;
////   DECODE_BASE64_STR decode_base64_str;
////
////   ST_REGISTER_MODULE st_register_module;
////   ST_UNREGISTER_MODULE st_unregister_module;
////   ST_CREATE_CATEGORY st_create_category;
////   ST_REMOVE_CATEGORY st_remove_category;
////   ST_SET_HCATEGORY st_set_hcategory;
////   ST_SET_CATEGORY st_set_category;
////
////   JI_TELL ji_tell;
////   JI_SEEK ji_seek;
////   JI_SET_JOB_FLAGS ji_set_job_flags;
////
////   LOGSTRING logstring;
////   LOGDATA logdata;
////
////   CREATE_OBJECT create_object;
////   SET_PASSWORD set_password;
////
////   ST_GET_NEXT_MODULE st_get_next_module;
////   ST_GET_NEXT_CATEGORY st_get_next_category;
////   ST_GET_CATEGORY_DATA st_get_category_data;
////   ST_EXPORT_STATS st_export_stats;
////
////   JI_GET_JOB_BY_ID ji_get_job_by_id;
////   JI_GET_JOB_TIMES ji_get_job_times;
////
////   SELECT_PRINTER select_printer;
////   PRINT_FILE print_file;
////
////   FM_COPY_MESSAGE fm_copy_message;
////   FM_DELETE_MESSAGE fm_delete_message;
////   FM_MOVE_MESSAGE fm_move_message;
////   FM_SAVE_MESSAGE_STATUS fm_save_message_status;
////   FM_SAVE_MESSAGE_READ_STATUS fm_save_message_read_status;
////   FM_SAVE_MESSAGE_FIELDS fm_save_message_fields;
////   FM_RELEASE_MESSAGE fm_release_message;
////
////   FM_FIND_MESSAGE_HEADER fm_find_message_header;
////   FM_EXTRACT_FILE_MESSAGE fm_extract_file_message;
////   FM_EXTRACT_MSG_MESSAGE fm_extract_msg_message;
////   FM_IS_NEWMAIL fm_is_newmail;
////
////   FM_CREATE_FOLDER fm_create_folder;
////   FM_CREATE_FOLDER_EX fm_create_folder_ex;
////   FM_OPEN_FOLDER fm_open_folder;
////   FM_CLOSE_FOLDER fm_close_folder;
////   FM_DELETE_FOLDER fm_delete_folder;
////   FM_RENAME_FOLDER fm_rename_folder;
////   FM_FIND_FOLDER fm_find_folder;
////   FM_FIND_FOLDER_BY_NAME fm_find_folder_by_name;
////   FM_GET_FOLDER fm_get_folder;
////
////   FM_GET_FOLDER_WINDOW fm_get_folder_window;
////   FM_COPY_FILE_INTO_FOLDER fm_copy_file_into_folder;
////
////   FM_STARTUP fm_startup;
////   FM_SHUTDOWN fm_shutdown;
////   FM_RESYNCH_NEWMAILBOX fm_resynch_newmailbox;
////   FM_MOUNT_MAILBOX fm_mount_mailbox;
////   FM_UNMOUNT_MAILBOX fm_unmount_mailbox;
////   FM_SEND_MESSAGE fm_send_message;
////   FM_GET_MESSAGE_CAPS fm_get_message_caps;
////   FM_GET_MAILBOX_UID fm_get_mailbox_uid;
////
////   FM_ASSOCIATE_FILE fm_associate_file;
////   FM_DISSOCIATE_FILE fm_dissociate_file;
////
////   DEPRECATED_FUNCTION uudecode;
////   DEPRECATED_FUNCTION uuencode;
////   CALC_CRC calc_crc;
////   GET_FILESIZE get_filesize;
////   DEPRECATED_FUNCTION fbinhex;
////   DEPRECATED_FUNCTION unbinhex_file;
////   UNBINHEX unbinhex;
////   BINHEX_INFO binhex_info;
////
////   FMM_UPDATE_HIERARCHY_ENTRY fmm_update_hierarchy_entry;
////   FMM_GET_ENTRY_MAILBOX fmm_get_entry_mailbox;
////   FMM_INITIALIZE_FOLMAN fmm_initialize_folman;
////   FMM_SHUTDOWN_FOLMAN fmm_shutdown_folman;
////   FMM_GET_OBJECT fmm_get_object;
////   FMM_GET_OBJECT_BY_ID fmm_get_object_by_id;
////
////   SCAN_ENCLOSURES scan_enclosures;
////   GET_ATTACHMENT_LIST get_attachment_list;
////   GET_ATTACHMENTS_FROM_FILE get_attachments_from_file;
////
////   PROCESS_FILENAME_STRING process_filename_string;
////   FMM_CREATE_OBJECT fmm_create_object;
////   FMM_DELETE_OBJECT fmm_delete_object;
////   FM_GET_INSTANCES fm_get_instances;
////   FMM_SET_PARENT fmm_set_parent;
////   FMM_RENAME_OBJECT fmm_rename_object;
////
////   FM_LOCK fm_lock;
////   FM_UNLOCK fm_unlock;
////   IS_NETWORK_READY is_network_ready;
////   MAKE_FILE_FROM_TEMPLATE make_file_from_template;
////
////   DL_OPEN_MEMBERSHIP dl_open_membership;
////   DL_CLOSE_MEMBERSHIP dl_close_membership;
////   DL_GETPOS dl_getpos;
////   DL_SETPOS dl_setpos;
////   DL_GET_NEXT_SUBSCRIBER dl_get_next_subscriber;
////   DL_FIND_SUBSCRIBER dl_find_subscriber;
////   DL_ADD_SUBSCRIBER dl_add_subscriber;
////   DL_UPDATE_SUBSCRIBER dl_update_subscriber;
////   DL_REMOVE_SUBSCRIBER dl_remove_subscriber;
////   DL_ACCESS dl_access;
////
////   JI_ACCESS_JOB_DATA ji_access_job_data;
////   JI_UNACCESS_JOB_DATA ji_unaccess_job_data;
////   JI_UPDATE_JOB_DATA ji_update_job_data;
////
////   EDIT_MESSAGE_HEADERS edit_message_headers;
////
////   JI_GET_JOB_STATE ji_get_job_state;
////   DECODE_MIME_HEADER_EX decode_mime_header_ex;
////   REGISTER_EVENT_HANDLER register_event_handler;
////   DEREGISTER_EVENT_HANDLER deregister_event_handler;
////   GENERATE_EVENT generate_event;
////
////   JI_ACQUIRE_QUEUE ji_acquire_queue;
////   JI_RELINQUISH_QUEUE ji_relinquish_queue;
////
////   DLIST_ACQUIRE_LIST dlist_acquire_list;
////   DLIST_RELEASE_LIST dlist_release_list;
////
////   DCR_ADD_TEXT_SECTION dcr_add_text_section;
////   DL_SEND_SUBSCRIPTION_MESSAGE dl_send_subscription_message;
////   DL_AUTOGENERATE_PASSWORD dl_autogenerate_password;
////   DL_VERIFY_LIST_PASSWORD dl_verify_list_password;
////   DL_SEND_SUBSCRIPTION_CONFIRMATION dl_send_subscription_confirmation;
////   DL_COMPLETE_SUBSCRIPTION_CONFIRMATION dl_complete_subscription_confirmation;
////   DLIST_COUNT dlist_count;
////
////   ENCODE_BASE64_FILE encode_base64_file;
////   DECODE_BASE64_FILE decode_base64_file;
////
////   //  Object Interface functions - new in Mercury/32 v4.6.
////   //  These function are only present when the vmajor/vminor
////   //  version fields of this block are 4.61 or later.
////
////   OIF_NEW oif_new;
////   OIF_DISPOSE_HANDLE oif_dispose_handle;
////   OIF_USE_HANDLE oif_use_handle;
////   OIF_DUPLICATE_OBJECT oif_duplicate_object;      //  Currently always NULL
////   OIF_COMPARE oif_compare;
////   OIF_COMPARE_STR oif_compare_str;
////
////   OIF_LOCK oif_lock;         //  Currently always NULL
////   OIF_UNLOCK oif_unlock;     //  Currently always NULL
////
////   OIF_GET_ATTRIBUTE oif_get_attribute;
////   OIF_GET_ATTRIBUTE_INFO oif_get_attribute_info;
////   OIF_SET_ATTRIBUTE oif_set_attribute;
////
////   OIF_DO_METHOD oif_do_method;
////
////   OIF_SCAN_FIRST oif_scan_first;
////   OIF_SCAN_LAST oif_scan_last;
////   OIF_SCAN_NEXT oif_scan_next;
////   OIF_SCAN_PREV oif_scan_prev;
////   OIF_END_SCAN oif_end_scan;
////
////   OIF_SEARCH_FIRST oif_search_first;
////   OIF_SEARCH_NEXT oif_search_next;
////   OIF_END_SEARCH oif_end_search;
////
////   OIF_ADD oif_add;
////   OIF_ADDTO oif_addto;
////   OIF_DELETE oif_delete;
////   OIF_CHANGE oif_change;
////   OIF_COMMIT_CHANGES oif_commit_changes;
////   OIF_CANCEL_CHANGES oif_cancel_changes;
////
////   OIF_REGISTER oif_register;
////   OIF_MAKE_HANDLE oif_make_handle;
////   OIF_CHANGE_DATA oif_change_data;
////   OIF_RECREATE_OBJECT oif_recreate_object;
////   OIF_OVERRIDE_OBJECT oif_override_object;
////   OIF_UNOVERRIDE_OBJECT oif_unoverride_object;
////
////   EXTRACT_TIME extract_time;
////   NORMALIZE_TIME normalize_time;
////   COMPARE_DATES compare_dates;
////   GET_TIMEZONE get_timezone;
////
////   OIF_HAS_TYPE oif_has_type;
////   } M_INTERFACE;

type

  PMInterface = ^TMInterface;
  PM_INTERFACE = PMInterface;
  {$EXTERNALSYM M_INTERFACE}
  M_INTERFACE = packed record
    dsize: Longint;                               //  Size of this structure
    vmajor: Byte;
    vminor: Byte;
    hMDIParent: HWND;
    get_variable:        GET_VARIABlE;                    // GET_VARIABLE;
    is_local_address:    IS_LOCAL_ADDRESS;                // IS_LOCAL_ADDRESS;
    is_group:            IS_GROUP;                        // IS_GROUP;
    parse_address:       PARSE_ADDRESS;                   // PARSE_ADDRESS;
    extract_one_address: EXTRACT_ONE_ADDRESS;             // EXTRACT_ONE_ADDRESS;
    extract_cqtext:      EXTRACT_CQTEXT;                  // EXTRACT_CQTEXT;
    dlist_info:          DLIST_INFO;                      // DLIST_INFO;
    send_notification:   SEND_NOTIFICATION;               // SEND_NOTIFICATION;
    get_delivery_path:   GET_DELIVERY_PATH;               // GET_DELIVERY_PATH;
    get_date_and_time:   GET_DATE_AND_TIME;               // GET_DATE_AND_TIME;
    verify_password:     VERIFY_PASSWORD;                 // VERIFY_PASSWORD;
    write_profile:       WRITE_PROFILE;                   // WRITE_PROFILE;
    module_state:        MODULE_STATE;                    // MODULE_STATE;
                                                          // Job control functions
    ji_scan_first_job:   JI_SCAN_FIRST_JOB;   // JI_SCAN_FIRST_JOB;
    ji_scan_next_job:    JI_SCAN_NEXT_JOB;    // JI_SCAN_NEXT_JOB;
    ji_end_scan:         JI_END_SCAN;         // JI_END_SCAN;
    ji_open_job:         JI_OPEN_JOB;         // JI_OPEN_JOB;
    ji_close_job:        JI_CLOSE_JOB;        // JI_CLOSE_JOB;
    ji_rewind_job:       JI_REWIND_JOB;       // JI_REWIND_JOB;
    ji_dispose_job:      JI_DISPOSE_JOB;      // JI_DISPOSE_JOB;
    ji_process_job:      JI_PROCESS_JOB;      // JI_PROCESS_JOB;
    ji_delete_job:       JI_DELETE_JOB;       // JI_DELETE_JOB;
    ji_abort_job:        JI_ABORT_JOB;        // JI_ABORT_JOB;
    ji_get_job_info:     JI_GET_JOB_INFO;     // JI_GET_JOB_INFO;
    ji_create_job:       JI_CREATE_JOB;       // JI_CREATE_JOB;
    ji_add_element:      JI_ADD_ELEMENT;      // JI_ADD_ELEMENT;
    ji_add_data:         JI_ADD_DATA;         // JI_ADD_DATA;
    ji_get_data:         JI_GET_DATA;         // JI_GET_DATA;
    ji_get_next_element: JI_GET_NEXT_ELEMENT;    // JI_GET_NEXT_ELEMENT;
    ji_set_element_status: JI_SET_ELEMENT_STATUS; // JI_SET_ELEMENT_STATUS;
    ji_set_element_resolvinfo: JI_SET_ELEMENT_RESOLVINFO; // JI_SET_ELEMENT_RESOLVINFO;
    ji_set_diagnostics: JI_SET_DIAGNOSTICS; // JI_SET_DIAGNOSTICS;
    ji_get_diagnostics: JI_GET_DIAGNOSTICS; // JI_GET_DIAGNOSTICS;
    ji_increment_time: JI_INCREMENT_TIME; // JI_INCREMENT_TIME;

    //  MNICA (Network interface) functions
    get_first_group_member: GET_FIRST_GROUP_MEMBER; // GET_FIRST_GROUP_MEMBER;
    get_next_group_member: GET_NEXT_GROUP_MEMBER;   // GET_NEXT_GROUP_MEMBER;
    end_group_scan: END_GROUP_SCAN;                 // END_GROUP_SCAN;
    is_valid_local_user: IS_VALID_LOCAL_USER;       // IS_VALID_LOCAL_USER;
    is_group_member: IS_GROUP_MEMBER;               // IS_GROUP_MEMBER;
    get_first_user_details: GET_FIRST_USER_DETAILS; // GET_FIRST_USER_DETAILS;
    get_next_user_details: GET_NEXT_USER_DETAILS;   // GET_NEXT_USER_DETAILS;
    get_user_details: GET_USER_DETAILS;             // GET_USER_DETAILS;
    end_user_scan: END_USER_SCAN;                   // END_USER_SCAN;
    read_pmprop: READ_PMPROP;                       // READ_PMPROP;
    change_ownership: CHANGE_OWNERSHIP;             // CHANGE_OWNERSHIP;
    begin_single_delivery: BEGIN_SINGLE_DELIVERY;   // BEGIN_SINGLE_DELIVERY;
    end_single_delivery: END_SINGLE_DELIVERY;       // END_SINGLE_DELIVERY;

    //  Miscellaneous functions
    mercury_command: MERCURY_COMMAND; // MERCURY_COMMAND;
    get_date_string: GET_DATE_STRING; // GET_DATE_STRING;
    rfc822_time: RFC822_TIME; // RFC822_TIME;
    rfc821_time: RFC821_TIME; // RFC821_TIME;

    //  File parsing and I/O functions
    fm_open_file: FM_OPEN_FILE;                     // FM_OPEN_FILE;
    fm_open_message: FM_OPEN_MESSAGE;               // FM_OPEN_MESSAGE;
    fm_close_message: FM_CLOSE_MESSAGE;             // FM_CLOSE_MESSAGE;
    fm_gets: FM_GETS; // FM_GETS;
    fm_getc: FM_GETC; // FM_GETC;
    fm_ungetc: FM_UNGETC; // FM_UNGETC;
    fm_read: FM_READ; // FM_READ;
    fm_getpos: FM_GETPOS; // FM_GETPOS;
    fm_setpos: FM_SETPOS; // FM_SETPOS;
    fm_get_folded_line: FM_GET_FOLDED_LINE; // FM_GET_FOLDED_LINE;
    fm_find_header: FM_FIND_HEADER; // FM_FIND_HEADER;
    fm_extract_message: FM_EXTRACT_MESSAGE; // FM_EXTRACT_MESSAGE;
    parse_header: PARSE_HEADER; // PARSE_HEADER;
    mime_prep_message: MIME_PREP_MESSAGE; // MIME_PREP_MESSAGE;
    parse_mime: Pointer; // _PARSE_MIME;
    free_mime: Pointer; // FREE_MIME;
    fake_imessage: Pointer; // FAKE_IMESSAGE;
    decode_mime_header: DECODE_MIME_HEADER; // DECODE_MIME_HEADER;
    encode_mime_header: ENCODE_MIME_HEADER; // ENCODE_MIME_HEADER;
    om_create_message: Pointer; // OM_CREATE_MESSAGE;
    om_dispose_message: Pointer; // OM_DISPOSE_MESSAGE;
    om_add_field: Pointer; // OM_ADD_FIELD;
    om_add_attachment: Pointer; // OM_ADD_ATTACHMENT;
    om_write_message: Pointer; // OM_WRITE_MESSAGE;
    om_send_message: Pointer; // OM_SEND_MESSAGE;
    encode_base64_str: Pointer; // ENCODE_BASE64_STR;
    decode_base64_str: Pointer; // DECODE_BASE64_STR;
    st_register_module: Pointer; // ST_REGISTER_MODULE;
    st_unregister_module: Pointer; // ST_UNREGISTER_MODULE;
    st_create_category: Pointer; // ST_CREATE_CATEGORY;
    st_remove_category: Pointer; // ST_REMOVE_CATEGORY;
    st_set_hcategory: Pointer; // ST_SET_HCATEGORY;
    st_set_category: Pointer; // ST_SET_CATEGORY;
    ji_tell: Pointer; // JI_TELL;
    ji_seek: Pointer; // JI_SEEK;
    ji_set_job_flags: Pointer; // JI_SET_JOB_FLAGS;
    LogString: LOGSTRING;
    logdata: LOGDATA;
    create_object: Pointer; // CREATE_OBJECT;
    set_password: Pointer; // SET_PASSWORD;
    st_get_next_module: Pointer; // ST_GET_NEXT_MODULE;
    st_get_next_category: Pointer; // ST_GET_NEXT_CATEGORY;
    st_get_category_data: Pointer; // ST_GET_CATEGORY_DATA;
    st_export_stats: Pointer; // ST_EXPORT_STATS;
    ji_get_job_by_id: Pointer; // JI_GET_JOB_BY_ID;
    ji_get_job_times: Pointer; // JI_GET_JOB_TIMES;
    select_printer: Pointer; // SELECT_PRINTER;
    print_file: Pointer; // PRINT_FILE;
    fm_copy_message: Pointer; // FM_COPY_MESSAGE;
    fm_delete_message: Pointer; // FM_DELETE_MESSAGE;
    fm_move_message: Pointer; // FM_MOVE_MESSAGE;
    fm_save_message_status: Pointer; // FM_SAVE_MESSAGE_STATUS;
    fm_save_message_read_status: Pointer; // FM_SAVE_MESSAGE_READ_STATUS;
    fm_save_message_fields: Pointer; // FM_SAVE_MESSAGE_FIELDS;
    fm_release_message: Pointer; // FM_RELEASE_MESSAGE;
    fm_find_message_header: Pointer; // FM_FIND_MESSAGE_HEADER;
    fm_extract_file_message: Pointer; // FM_EXTRACT_FILE_MESSAGE;
    fm_extract_msg_message: Pointer; // FM_EXTRACT_MSG_MESSAGE;
    fm_is_newmail: Pointer; // FM_IS_NEWMAIL;
    fm_create_folder: Pointer; // FM_CREATE_FOLDER;
    fm_create_folder_ex: Pointer; // FM_CREATE_FOLDER_EX;
    fm_open_folder: Pointer; // FM_OPEN_FOLDER;
    fm_close_folder: Pointer; // FM_CLOSE_FOLDER;
    fm_delete_folder: Pointer; // FM_DELETE_FOLDER;
    fm_rename_folder: Pointer; // FM_RENAME_FOLDER;
    fm_find_folder: Pointer; // FM_FIND_FOLDER;
    fm_find_folder_by_name: Pointer; // FM_FIND_FOLDER_BY_NAME;
    fm_get_folder: Pointer; // FM_GET_FOLDER;
    fm_get_folder_window: Pointer; // FM_GET_FOLDER_WINDOW;
    fm_copy_file_into_folder: Pointer; // FM_COPY_FILE_INTO_FOLDER;
    fm_startup: Pointer; // FM_STARTUP;
    fm_shutdown: Pointer; // FM_SHUTDOWN;
    fm_resynch_newmailbox: Pointer; // FM_RESYNCH_NEWMAILBOX;
    fm_mount_mailbox: Pointer; // FM_MOUNT_MAILBOX;
    fm_unmount_mailbox: Pointer; // FM_UNMOUNT_MAILBOX;
    fm_send_message: Pointer; // FM_SEND_MESSAGE;
    fm_get_message_caps: Pointer; // FM_GET_MESSAGE_CAPS;
    fm_get_mailbox_uid: Pointer; // FM_GET_MAILBOX_UID;
    fm_associate_file: Pointer; // FM_ASSOCIATE_FILE;
    fm_dissociate_file: Pointer; // FM_DISSOCIATE_FILE;
    uudecode: DEPRECATED_FUNCTION; 
    uuencode: DEPRECATED_FUNCTION; 
    calc_crc: CALC_CRC;
    get_filesize: Pointer; // GET_FILESIZE;
    fbinhex: DEPRECATED_FUNCTION;
    unbinhex_file: DEPRECATED_FUNCTION;
    unbinhex: Pointer; // UNBINHEX;
    binhex_info: Pointer; // BINHEX_INFO;
    fmm_update_hierarchy_entry: Pointer; // FMM_UPDATE_HIERARCHY_ENTRY;
    fmm_get_entry_mailbox: Pointer; // FMM_GET_ENTRY_MAILBOX;
    fmm_initialize_folman: Pointer; // FMM_INITIALIZE_FOLMAN;
    fmm_shutdown_folman: Pointer; // FMM_SHUTDOWN_FOLMAN;
    fmm_get_object: Pointer; // FMM_GET_OBJECT;
    fmm_get_object_by_id: Pointer; // FMM_GET_OBJECT_BY_ID;
    scan_enclosures: Pointer; // SCAN_ENCLOSURES;
    get_attachment_list: Pointer; // GET_ATTACHMENT_LIST;
    get_attachments_from_file: Pointer; // GET_ATTACHMENTS_FROM_FILE;
    process_filename_string: Pointer; // PROCESS_FILENAME_STRING;
    fmm_create_object: Pointer; // FMM_CREATE_OBJECT;
    fmm_delete_object: Pointer; // FMM_DELETE_OBJECT;
    fm_get_instances: Pointer; // FM_GET_INSTANCES;
    fmm_set_parent: Pointer; // FMM_SET_PARENT;
    fmm_rename_object: Pointer; // FMM_RENAME_OBJECT;
    fm_lock: Pointer; // FM_LOCK;
    fm_unlock: Pointer; // FM_UNLOCK;
    is_network_ready: Pointer; // IS_NETWORK_READY;
    make_file_from_template: Pointer; // MAKE_FILE_FROM_TEMPLATE;
    dl_open_membership: Pointer; // DL_OPEN_MEMBERSHIP;
    dl_close_membership: Pointer; // DL_CLOSE_MEMBERSHIP;
    dl_getpos: Pointer; // DL_GETPOS;
    dl_setpos: Pointer; // DL_SETPOS;
    dl_get_next_subscriber: Pointer; // DL_GET_NEXT_SUBSCRIBER;
    dl_find_subscriber: Pointer; // DL_FIND_SUBSCRIBER;
    dl_add_subscriber: Pointer; // DL_ADD_SUBSCRIBER;
    dl_update_subscriber: Pointer; // DL_UPDATE_SUBSCRIBER;
    dl_remove_subscriber: Pointer; // DL_REMOVE_SUBSCRIBER;
    dl_access: Pointer; // DL_ACCESS;
    ji_access_job_data: Pointer; // JI_ACCESS_JOB_DATA;
    ji_unaccess_job_data: Pointer; // JI_UNACCESS_JOB_DATA;
    ji_update_job_data: Pointer; // JI_UPDATE_JOB_DATA;
    edit_message_headers: Pointer; // EDIT_MESSAGE_HEADERS;
    ji_get_job_state: Pointer; // JI_GET_JOB_STATE;
    decode_mime_header_ex: Pointer; // DECODE_MIME_HEADER_EX;
    register_event_handler: REGISTER_EVENT_HANDLER;
    deregister_event_handler: DEREGISTER_EVENT_HANDLER;
    generate_event: GENERATE_EVENT;
    ji_acquire_queue: Pointer; // JI_ACQUIRE_QUEUE;
    ji_relinquish_queue: Pointer; // JI_RELINQUISH_QUEUE;
    dlist_acquire_list: Pointer; // DLIST_ACQUIRE_LIST;
    dlist_release_list: Pointer; // DLIST_RELEASE_LIST;
    dcr_add_text_section: Pointer; // DCR_ADD_TEXT_SECTION;
    dl_send_subscription_message: Pointer; // DL_SEND_SUBSCRIPTION_MESSAGE;
    dl_autogenerate_password: Pointer; // DL_AUTOGENERATE_PASSWORD;
    dl_verify_list_password: Pointer; // DL_VERIFY_LIST_PASSWORD;
    dl_send_subscription_confirmation: Pointer; // DL_SEND_SUBSCRIPTION_CONFIRMATION;
    dl_complete_subscription_confirmation: Pointer; // DL_COMPLETE_SUBSCRIPTION_CONFIRMATION;
    dlist_count: Pointer; // DLIST_COUNT;
    encode_base64_file: Pointer; // ENCODE_BASE64_FILE;
    decode_base64_file: Pointer; // DECODE_BASE64_FILE;
                                                  //  Object Interface functions - new in Mercury/32 v4.6.
                                                  //  These function are only present when the vmajor/vminor
                                                  //  version fields of this block are 4.61 or later.
    oif_new: OIF_NEW;
    oif_dispose_handle: OIF_DISPOSE_HANDLE;
    oif_use_handle: OIF_USE_HANDLE; 
    oif_duplicate_object: OIF_DUPLICATE_OBJECT;   //  Currently always NULL 
    oif_compare: OIF_COMPARE; 
    oif_compare_str: OIF_COMPARE_STR; 
    oif_lock: OIF_LOCK;                           //  Currently always NULL 
    oif_unlock: OIF_UNLOCK;                       //  Currently always NULL 
    oif_get_attribute: OIF_GET_ATTRIBUTE; 
    oif_get_attribute_info: OIF_GET_ATTRIBUTE_INFO; 
    oif_set_attribute: OIF_SET_ATTRIBUTE;
    oif_do_method: OIF_DO_METHOD; 
    oif_scan_first: OIF_SCAN_FIRST; 
    oif_scan_last: OIF_SCAN_LAST; 
    oif_scan_next: OIF_SCAN_NEXT;
    oif_scan_prev: OIF_SCAN_PREV;
    oif_end_scan: OIF_END_SCAN; 
    oif_search_first: OIF_SEARCH_FIRST; 
    oif_search_next: OIF_SEARCH_NEXT; 
    oif_end_search: OIF_END_SEARCH; 
    oif_add: OIF_ADD; 
    oif_addto: OIF_ADDTO;
    oif_delete: OIF_DELETE; 
    oif_change: OIF_CHANGE; 
    oif_commit_changes: OIF_COMMIT_CHANGES; 
    oif_cancel_changes: OIF_CANCEL_CHANGES; 
    oif_register: OIF_REGISTER; 
    oif_make_handle: OIF_MAKE_HANDLE; 
    oif_change_data: OIF_CHANGE_DATA; 
    oif_recreate_object: OIF_RECREATE_OBJECT; 
    oif_override_object: OIF_OVERRIDE_OBJECT; 
    oif_unoverride_object: OIF_UNOVERRIDE_OBJECT; 
    extract_time: EXTRACT_TIME; // EXTRACT_TIME;
    normalize_time: NORMALIZE_TIME; // NORMALIZE_TIME;
    compare_dates: COMPARE_DATES; // COMPARE_DATES;
    get_timezone: GET_TIMEZONE; // GET_TIMEZONE;
    oif_has_type: OIF_HAS_TYPE; // OIF_HAS_TYPE;
  end;
  TMInterface = M_INTERFACE;

const

//  Convenience macros: allow calls to internal Mercury functions to
//  be made in the same way as they would be in the core code (good
//  for portability).

//  Values for the "flags" field of print_file

  {$EXTERNALSYM PRT_MESSAGE}
  PRT_MESSAGE                         = 1;  //  Print as an RFC822 message
  {$EXTERNALSYM PRT_REFORMAT}
  PRT_REFORMAT                        = 2;  //  Reformat long lines when printing
  {$EXTERNALSYM PRT_TIDY}
  PRT_TIDY                            = 4;  //  Print only "important" headers
  {$EXTERNALSYM PRT_FOOTER}
  PRT_FOOTER                          = 8;  //  Print a footer on each page
  {$EXTERNALSYM PRT_NOHEADERS}
  PRT_NOHEADERS                       = 16;  //  Print no message headers
  {$EXTERNALSYM PRT_FIRSTONLY}
  PRT_FIRSTONLY                       = 32;  //  Print only first line of headers
  {$EXTERNALSYM PRT_ITALICS}
  PRT_ITALICS                         = 64;  //  Print quoted text in italics

// extern M_INTERFACE *mi;

//#define get_variable(x) (mi->get_variable (x))
//#define is_local_address(a,u,s) (mi->is_local_address (a, u, s))
//#define is_group(a,h,g) (mi->is_group (a, h, g))
//#define parse_address(t,s,l) (mi->parse_address (t, s, l))
//#define extract_one_address(d,s,o) (mi->extract_one_address (d, s, o))
//#define extract_cqtext(d,s,l) (mi->extract_cqtext (d, s, l))
//#define dlist_info (d,l,n,a,e,m) (mi->dlist_info (d, l, n, a, e, m))
//#define send_notification(u,h,m) (mi->send_notification (u, h, m))
//#define get_delivery_path(p,u,h) (mi->get_delivery_path (p, u, h))
//#define get_date_and_time(b) (mi->get_date_and_time (b))
//#define verify_password(u,s,p,e) (mi->verify_password (u, s, p, e))
//#define write_profile(s,f) (mi->write_profile (s, f))
//#define module_state(m,v,s) (mi->module_state (m, v, s))
//
//#define ji_scan_first_job(t,m,d) (mi->ji_scan_first_job (t,m,d))
//#define ji_scan_next_job(d) (mi->ji_scan_next_job (d))
//#define ji_end_scan(d) (mi->ji_end_scan (d))
//#define ji_open_job(j) (mi->ji_open_job (j))
//#define ji_close_job(j) (mi->ji_close_job (j))
//#define ji_rewind_job(j,f) (mi->ji_rewind_job (j,f))
//#define ji_dispose_job(j) (mi->ji_dispose_job (j))
//#define ji_process_job(j) (mi->ji_process_job (j))
//#define ji_delete_job(j) (mi->ji_delete_job (j))
//#define ji_abort_job(j,f) (mi->ji_abort_job (j, f))
//#define ji_get_job_info(j,i) (mi->ji_get_job_info (j, i))
//#define ji_create_job(t,f,s) (mi->ji_create_job (t,f,s))
//#define ji_add_element(j,a) (mi->ji_add_element (j,a))
//#define ji_add_data(j,d) (mi->ji_add_data (j,d))
//#define ji_get_data(j,b,l) (mi->ji_get_data (j,b,l))
//#define ji_get_next_element(j,t,i) (mi->ji_get_next_element (j,t,i))
//#define ji_set_element_status(j,m,d) (mi->ji_set_element_status (j,m,d))
//#define ji_set_element_resolvinfo(j,k,l,m,n) (mi->ji_set_element_resolvinfo (j,k,l,m,n))
//#define ji_set_diagnostics(j,w,t) (mi->ji_set_diagnostics (j,w,t))
//#define ji_get_diagnostics(j,w,f) (mi->ji_get_diagnostics (j,w,f))
//#define ji_increment_time(t,s) (mi->ji_increment_time (t,s))
//#define ji_tell(j,s) (mi->ji_tell (j,s))
//#define ji_seek(j,o,s) (mi->ji_seek(j,o,s))
//#define ji_set_job_flags(j,f) (mi->ji_set_job_flags(j,f))
//#define ji_acquire_queue(w) (mi->ji_acquire_queue(w))
//#define ji_relinquish_queue(w) (mi->ji_relinquish_queue(w))
//
//#define get_first_group_member(g,h,m,l,d) (mi->get_first_group_member(g,h,m,l,d))
//#define get_next_group_member(m,l,d) (mi->get_next_group_member(m,l,d))
//#define end_group_scan(d) (mi->end_group_scan(d))
//#define is_valid_local_user(a,u,h) (mi->is_valid_local_user(a,u,h))
//#define is_group_member(h,u,g) (mi->is_group_member(h,u,g))
//#define get_first_user_details(h,n,u,ul,a,al,f,fl,d) (mi->get_first_user_details(h,n,u,ul,a,al,f,fl,d))
//#define get_next_user_details(u,ul,a,al,f,fl,d) (mi->get_next_user_details(u,ul,a,al,f,fl,d))
//#define get_user_details(h,m,u,ul,a,al,f,fl) (mi->get_user_details(h,m,u,ul,a,al,f,fl))
//#define end_user_scan(d) (mi->end_user_scan(d))
//#define read_pmprop(u,s,p) (mi->read_pmprop(u,s,p))
//#define change_ownership(f,h,n) (mi->change_ownership(f,h,n))
//#define begin_single_delivery(u,s,d) (mi->begin_single_delivery(u,s,d))
//#define end_single_delivery(d) (mi->end_single_delivery(d))
//#define is_network_ready(q) (mi->is_network_ready(q))
//
//#define mercury_command(s,p1,p2) (mi->mercury_command(s,p1,p2))
//#define get_date_string(s,b,d) (mi->get_date_string(s,b,d))
//#define rfc822_time(s) (mi->rfc822_time(s))
//#define rfc821_time(s) (mi->rfc821_time(s))
//
//#ifndef M_NO_FOLDERING
//#define fm_open_file(p,f) (mi->fm_open_file(p,f))
//#define fm_open_message(i,f) (mi->fm_open_message(i,f))
//#define fm_close_message(i) (mi->fm_close_message(i))
//#define fm_gets(b,m,i) (mi->fm_gets(b,m,i))
//#define fm_getc(i) (mi->fm_getc(i))
//#define fm_ungetc(c,i) (mi->fm_ungetc(c,i))
//#define fm_read(i,b,s) (mi->fm_read(i,b,s))
//#define fm_getpos(f) (mi->fm_getpos(f))
//#define fm_setpos(f,o) (mi->fm_setpos(f,o))
//#define fm_get_folded_line(f,l,x) (mi->fm_get_folded_line(f,l,x))
//#define fm_find_header(i,n,b,l) (mi->fm_find_header(i,n,b,l))
//#define fm_extract_message(j,n,f) (mi->fm_extract_message(j,n,f))
//
//#define parse_header(f,m) (mi->parse_header(f,m))
//#endif   // M_NO_FOLDERING
//
//#ifndef M_NO_MIME
//#define mime_prep_message(i,f,h) (mi->mime_prep_message(i,f,h))
//#define parse_mime(i,m) (mi->parse_mime(i,m))
//#define free_mime(m) (mi->free_mime(m))
//#define fake_imessage(i,s,m,e,b) (mi->fake_imessage(i,s,m,e,b))
//#define decode_mime_header(d,s) (mi->decode_mime_header(d,s))
//#define encode_mime_header(d,s,r) (mi->encode_mime_header(d,s,r))
//#define encode_base64_file(i,o) (mi->encode_base64_file(i,o))
//#define decode_base64_file(i,o,b) (mi->decode_base64_file(i,o,b))
//#endif
//
//#define om_create_message(m,f) (mi->om_create_message(m,f))
//#define om_dispose_message(m) (mi->om_dispose_message(m))
//#define om_add_field(m,s,d) (mi->om_add_field(m,s,d))
//#define om_add_attachment(m,f,t,d,e,g,r) (mi->om_add_attachment(m,f,t,d,e,g,r))
//#define om_write_message(m,f) (mi->om_write_message(m,f))
//#define om_send_message(m,e) (mi->om_send_message(m,e))
//
//#ifndef M_NO_MIME
//#define encode_base64_str(d,s,l) (mi->encode_base64_str(d,s,l))
//#define decode_base64_str(d,s,t) (mi->decode_base64_str(d,s,t))
//#endif
//
//#define st_register_module(m) (mi->st_register_module(m))
//#define st_unregister_module(h) (mi->st_unregister_module(h))
//#define st_create_category(m,c,t,y,l,f) (mi->st_create_category(m,c,t,y,l,f))
//#define st_remove_category(m,c) (mi->st_remove_category(m,c))
//#define st_set_hcategory(c,d) (mi->st_set_hcategory(c,d))
//#define st_set_category(m,c,d) (mi->st_set_category(m,c,d))
//
//#define logstring(l,p,s) (mi->logstring(l,p,s))
//// "logdata" has variable parameters and cannot be accessed via a macro
//
//#define create_object(n,t,i,f) (mi->create_object(n,t,i,f))
//#define set_password(u,h,n,o,s) (mi->set_password(u,h,n,o,s))
//
//#define st_get_next_module(m,n) (mi->st_get_next_module(m,n))
//#define st_get_next_category(m,h,c,t,l,f) (mi->st_get_next_category(m,h,c,t,l,f))
//#define st_get_category_data(c,d) (mi->st_get_category_data(c,d))
//#define st_export_stats(m,f,l) (mi->st_export_stats(m,f,l))
//
//#define ji_get_job_by_id(i) (mi->ji_get_job_by_id(i))
//#define ji_get_job_times(j,s,r) (mi->ji_get_job_times(j,s,r))
//
//#define select_printer(d,m) (mi->select_printer(d,m))
//#define print_file(f,p,l,m,b,t,u,n,z) (mi->print_file(f,p,l,m,b,t,u,n,z))
//
//#ifndef M_NO_FOLDERING
//#define fm_startup(u,p,f) (mi->fm_startup(u,p,f))
//#define fm_shutdown(f,t) (mi->fm_shutdown(f,t))
//#define fm_lock(f) (mi->fm_lock(f))
//#define fm_unlock(f) (mi->fm_unlock(f))
//
//#define fm_open_folder(f,h,g) (mi->fm_open_folder(f,h,g))
//#define fm_close_folder(f) (mi->fm_close_folder(f))
//
//#define fm_copy_message(i,f) (mi->fm_copy_message(i,f))
//#define fm_move_message(i,f) (mi->fm_move_message(i,f))
//#define fm_delete_message(i,f) (mi->fm_delete_message(i,f))
//#define fm_copy_file_into_folder(d,f,i,g,m) (mi->fm_copy_file_into_folder(d,f,i,g,m))
//
//#define fm_send_message(f,m,p1,p2) (mi->fm_send_message(f,m,p1,p2))
//
//#define fmm_get_object(f,m,o,e) (mi->fmm_get_object(f,m,o,e))
//#define fmm_get_object_by_id(f,i,e) (mi->fmm_get_object_by_id(f,i,e))
//#define fmm_initialize_folman(f) (mi->fmm_initialize_folman(f))
//#define fmm_shutdown_folman(f) (mi->fmm_shutdown_folman(f))
//#define fmm_create_object(d,o,n,f,p,e) (mi->fmm_create_object(d,o,n,f,p,e))
//#define fmm_delete_object(f,i) (mi->fmm_delete_object(f,i))
//#define fm_get_instances(d,f) (mi->fm_get_instances(d,f))
//#define fmm_set_parent(f,i,p) (mi->fmm_set_parent(f,i,p))
//#define fmm_rename_object(f,i,n) (mi->fmm_rename_object(f,i,n))
//
//#define fm_save_message_status(i) (mi->fm_save_message_status(i))
//#define fm_save_message_read_status(i,r) (mi->fm_save_message_read_status(i,r))
//#endif   //  M_NO_FOLDERING
//
//#define process_filename_string(d,s) (mi->process_filename_string(d,s))
//#define make_file_from_template(t,o,r,m,p) (mi->make_file_from_template(t,o,r,m,p))
//
//#define dl_open_membership(d,r) (mi->dl_open_membership(d,r))
//#define dl_close_membership(d) (mi->dl_close_membership(d))
//#define dl_getpos(d) (mi->dl_getpos(d))
//#define dl_setpos(d,p) (mi->dl_setpos(d,p))
//#define dl_get_next_subscriber(d,s,f) (mi->dl_get_next_subscriber(d,s,f))
//#define dl_find_subscriber(d,s,a) (mi->dl_find_subscriber(d,s,a))
//#define dl_add_subscriber(d,s) (mi->dl_add_subscriber(d,s))
//#define dl_update_subscriber(d,s) (mi->dl_update_subscriber(d,s))
//#define dl_remove_subscriber(d,a) (mi->dl_remove_subscriber(d,a))
//#define dl_access(a) (mi->dl_access(a))
//
//#define ji_access_job_data(j,d,l) (mi->ji_access_job_data(j,d,l))
//#define ji_unaccess_job_data(j) (mi->ji_unaccess_job_data(j))
//#define ji_update_job_data(j,d) (mi->ji_update_job_data(j,d))
//
//#define edit_message_headers(f,a,d) (mi->edit_message_headers(f,a,d))
//
//#define ji_get_job_state(j,t,s) (mi->ji_get_job_state(j,t,s))
//#define decode_mime_header_ex(d,l,s,f) (mi->decode_mime_header_ex(d,l,s,f))
//#define register_event_handler(m,e,v,c) (mi->register_event_handler(m,e,v,c))
//#define deregister_event_handler(m,e,p) (mi->deregister_event_handler(m,e,p))
//#define generate_event(m,e,d,s) (mi->generate_event(m,e,d,s))
//
//#define dlist_acquire_list(d,w) (mi->dlist_acquire_list(d,w))
//#define dlist_release_list(d) (mi->dlist_release_list(d))
//
//#define dcr_add_text_section(d,s,t,h,f) (mi->dcr_add_text_section(d,s,t,h,f))
//
//#define dl_send_subscription_message(d,s,b) (mi->dl_send_subscription_message(d,s,b))
//#define dl_autogenerate_password(p,l,f) (mi->dl_autogenerate_password(p,l,f))
//#define dl_verify_list_password(d,s,c) (mi->dl_verify_list_password(d,s,c))
//#define dl_send_subscription_confirmation(d,a,n,p) (mi->dl_send_subscription_confirmation(d,a,n,p))
//#define dl_complete_subscription_confirmation(d,s,i) (mi->dl_complete_subscription_confirmation(d,s,i))
//#define dlist_count(f) (mi->dlist_count(f))
//
//#define oif_new(n,t,o,f) (mi->oif_new(n,t,o,f))
//#define oif_dispose_handle(o) (mi->oif_dispose_handle(o))
//#define oif_use_handle(o) (mi->oif_use_handle(o))
//#define oif_compare(o1,o2,a,r) (mi->oif_compare(o1,o2,a,r))
//#define oif_compare_str(o1,o2,a,f,r) (mi->oif_compare_str(o1,o2,a,f,r))
//
//#define oif_lock(o) (mi->oif_lock(o))
//#define oif_unlock(o) (mi->oif_unlock(o))
//
//#define oif_get_attribute(o,a,b,l) (mi->oif_get_attribute(o,a,b,l))
//#define oif_get_attribute_info(o,a,i) (mi->oif_get_attribute_info(o,a,i))
//#define oif_set_attribute(o,a,b,l) (mi->oif_set_attribute(o,a,b,l))
//
//#define oif_do_method(o,m,ib,il,ob,ol) (mi->oif_do_method(o,m,ib,il,ob,ol))
//
//#define oif_scan_first(c,o,r) (mi->oif_scan_first(c,o,r))
//#define oif_scan_last(c,o,r) (mi->oif_scan_last(c,o,r))
//#define oif_scan_next(c,o,r) (mi->oif_scan_next(c,o,r))
//#define oif_scan_prev(c,o,r) (mi->oif_scan_prev(c,o,r))
//#define oif_end_scan(c,r) (mi->oif_end_scan(c,r))
//
//#define oif_search_first(c,e,l,o,r) (mi->oif_search_first(c,e,l,o,r))
//#define oif_search_next(c,o,r) (mi->oif_search_next(c,o,r))
//#define oif_end_search(c,r) (mi->oif_end_search(c,r))
//
//#define oif_add(c,n,t,w,f) (mi->oif_add(c,n,t,w,f))
//#define oif_addto(c,o,n) (mi->oif_addto(c,o,n))
//
//#define oif_delete(o) (mi->oif_delete(o))
//#define oif_change(o,c) (mi->oif_change(o,c))
//#define oif_commit_changes(o,c) (mi->oif_commit_changes(o,c))
//#define oif_cancel_changes(o,c) (mi->oif_cancel_changes(o,c))
//
//#define oif_register(o) (mi->oif_register(o))
//#define oif_make_handle(o,d,b) (mi->oif_make_handle(o,d,b))
//#define oif_change_data(o,d,n) (mi->oif_change_data(o,d,n))
//
//#define oif_recreate_object(d,l,o,c,a) (mi->oif_recreate_object(d,l,o,c,a))
//
//#define oif_override_object(o,d,a) (mi->oif_override_object(o,d,a))
//#define oif_unoverride_object(o,d,a) (mi->oif_unoverride_object (o,d,a))
//
//#define extract_time(d,t,f) (mi->extract_time(d,t,f))
//#define normalize_time(t,o) (mi->normalize_time(t,o))
//#define compare_dates(s,d) (mi->compare_dates(s,d))
//#define get_timezone(b) (mi->get_timezone(b))
//
//#define oif_has_type(o,t) (mi->oif_has_type(o,t))
//
//#endif  //  USES_M_INTERFACE


(****************************************************************************
  MercuryB SubService Daemons are a specialized form of Daemon loaded by the
  MercuryB HTTP server to provide web services.
****************************************************************************)

  {$EXTERNALSYM MAX_SERVICE_NAME}
  MAX_SERVICE_NAME                    = 80; 

  {$EXTERNALSYM MBS_SESSION_SERVICE}
  MBS_SESSION_SERVICE                 = 1; 
  {$EXTERNALSYM MBS_CUSTOM_LOGIN}
  MBS_CUSTOM_LOGIN                    = 2; 
  {$EXTERNALSYM MBS_COOKIE_STATE}
  MBS_COOKIE_STATE                    = 4; 

//typedef struct _condef CONDEF;

//enum
//   {
//   HERR_BAD_METHOD = 1,
//   HERR_UNSUPPORTED_PROTOCOL,
//   HERR_NOT_FOUND,
//   HERR_BAD_URI,
//   HERR_BAD_SERVICE,
//   HERR_BAD_TICKET,
//   HERR_BAD_REQUEST,
//   HERR_SERVER_ERROR,
//   HERR_BAD_TICKET2
//   };

//enum
//   {
//   MBC_INITIALIZE = 1,
//   MBC_LOGIN,
//   MBC_LOGOUT,
//   MBC_PROCESS,
//   MBC_TERMINATE,
//   MBC_SHUTDOWN
//   };

////typedef struct
////   {
////   char servicename [80];
////   UINT_32 flags;
////   MBHANDLER handler;
////   HINSTANCE hLib;
////   } SERVICEDEF;

//typedef void * (*PARSE_URI) (char *uri);

type
  PARSE_URI                = function (uri: PAnsiChar): Pointer; cdecl;

//typedef void   (*RELEASE_URI) (void *data);
  RELEASE_URI              = procedure (data: Pointer); cdecl;

  PARSE_REQUEST            = function (condef: Pointer): Pointer; cdecl;
  GET_URI_ATTRIBUTE        = function (data: Pointer; attr: PAnsiChar): PAnsiChar; cdecl;
  GET_URI_ATTRIBUTE_N      = function (data: Pointer; aval: PPAnsiChar; n: INT_32): PAnsiChar; cdecl;
  MAKE_URI                 = function (condef: Pointer; dest: PAnsiChar; dlen: INT_32; body: PAnsiChar): PAnsiChar; cdecl;
  CHECK_EXISTENCE          = function (path: PAnsiChar): INT_32; cdecl;
  TRIM_TRAILING_WHITESPACE = procedure (str: PAnsiChar); cdecl;
  TRIM_NEWLINE             = procedure (str: PAnsiChar); cdecl;
  MAKE_PATH                = function (line, basedir, fname: PAnsiChar): PAnsiChar; cdecl;
  MAKE_BASE_PATH           = function (line: PAnsiChar; fname: PAnsiChar): PAnsiChar; cdecl;
  MAKE_EXE_PATH            = function (line: PAnsiChar; fname: PAnsiChar): PAnsiChar; cdecl;
  LOG_EVENT                = function(base_fname: PAnsiChar; id: INT_32; &type: AnsiChar; fmt: PAnsiChar): Integer; cdecl varargs;
  FINDNAME                 = function (fname: PAnsiChar): PAnsiChar; cdecl;
  FIND_EXTENSION           = function (fname: PAnsiChar): PAnsiChar; cdecl;
  SKIPWS                   = function (str: PAnsiChar): PAnsiChar; cdecl;

//typedef void * (*PARSE_REQUEST) (void *condef);
//typedef char * (*GET_URI_ATTRIBUTE) (void *data, char *attr);
//typedef char * (*GET_URI_ATTRIBUTE_N) (void *data, char **aval, int n);
//typedef char * (*MAKE_URI) (void *condef, char *dest, int dlen, char *body);
//typedef int    (*CHECK_EXISTENCE) (char *path);
//typedef void   (*TRIM_TRAILING_WHITESPACE) (char *str);
//typedef void   (*TRIM_NEWLINE) (char *str);
//typedef char * (*MAKE_PATH) (char *line, char *basedir, char *fname);
//typedef char * (*MAKE_BASE_PATH) (char *line, char *fname);
//typedef char * (*MAKE_EXE_PATH) (char *line, char *fname);
//typedef void   (*LOGDATA) (INT_16 ltype, INT_16 priority, char *fmt, ...);
//typedef int    (*LOG_EVENT) (char *base_fname, INT_32 id, char type, char *fmt, ...);
//typedef char * (*FINDNAME) (char *fname);
//typedef char * (*FIND_EXTENSION) (char *fname);
//typedef char * (*SKIPWS) (char *str);


//typedef struct mb_services
//   {
//   UINT_32 ssize;
//   UINT_32 sversion;
//
//   PARSE_URI parse_uri;
//   RELEASE_URI release_uri;
//   GET_URI_ATTRIBUTE get_uri_attribute;
//   GET_URI_ATTRIBUTE_N get_uri_attribute_n;
//   PARSE_REQUEST parse_request;
//   MAKE_URI make_uri;
//   CHECK_EXISTENCE check_existence;
//   TRIM_TRAILING_WHITESPACE trim_trailing_whitespace;
//   TRIM_NEWLINE trim_newline;
//   MAKE_PATH make_path;
//   MAKE_BASE_PATH make_base_path;
//   MAKE_EXE_PATH make_exe_path;
//   LOGDATA logdata;
//   LOG_EVENT log_event;
//   FINDNAME findname;
//   FIND_EXTENSION find_extension;
//   SKIPWS skipws;
//   } MB_SERVICES;
  PMB_Services = ^MB_Services;
  MB_Services = packed record
    SSize, SVersion: UINT_32;

    ParseUri: PARSE_URI;
    ReleaseUri: RELEASE_URI;
    GetUriAttribute: GET_URI_ATTRIBUTE;
    GetUriAttributeN: GET_URI_ATTRIBUTE_N;
    ParseRequest: PARSE_REQUEST;
    MakeUri: MAKE_URI;
    CheckExistence: CHECK_EXISTENCE;
    TrimTrailingWhiteSpace: TRIM_TRAILING_WHITESPACE;
    TrimNewLine: TRIM_NEWLINE;
    MakePath: MAKE_PATH;
    MakeBasePath: MAKE_BASE_PATH;
    MakeExePath: MAKE_EXE_PATH;
    LogData: LOGDATA;
    LogEvent: LOG_EVENT;
    FindName: FINDNAME;
    FindExtension: FIND_EXTENSION;
    SkipWS: SKIPWS;
  end;

const

  {$EXTERNALSYM MBCF_NEW}
  MBCF_NEW                            = 1;
  {$EXTERNALSYM MBCF_SECURE}
  MBCF_SECURE                         = 2;  //  SSL connection
  {$EXTERNALSYM MBCF_END_SESSION}
  MBCF_END_SESSION                    = 4;
  {$EXTERNALSYM MBCF_NO_CACHE}
  MBCF_NO_CACHE                       = 8;
  {$EXTERNALSYM MBCF_ACTIVE}
  MBCF_ACTIVE                         = $10000;
  {$EXTERNALSYM MBCF_USER_1}
  MBCF_USER_1                         = $1000000;
  {$EXTERNALSYM MBCF_USER_2}
  MBCF_USER_2                         = $2000000;
  {$EXTERNALSYM MBCF_USER_3}
  MBCF_USER_3                         = $4000000;
  {$EXTERNALSYM MBCF_USER_4}
  MBCF_USER_4                         = $8000000;


//enum
//   {
//   METHOD_GET,
//   METHOD_POST,
//   METHOD_HEAD,
//   METHOD_UNKNOWN
//   };

  {$EXTERNALSYM METHOD_URLENCODED}
  METHOD_URLENCODED                   = 1024; 

////typedef struct _condef
////   {
////   UINT_32 ssize;       //  Size of this structure in bytes
////   UINT_32 sversion;    //  Version of this structure
////   SERVICEDEF *svc;     //  Sub-service associated with this conversation
////   UINTP data;          //  Sub-service specific data
////   UINT_32 flags;       //  MBCF_* flags for this command
////   UINT_32 protocol;    //  Protocol level of conversation - 9, 10 or 11
////   UINT_32 method;      //  Method used to submit this command
////   M_INTERFACE *mi;     //  Mercury protocol module function block
////   MB_SERVICES *mbs;    //  Useful utility functions for external subservices
////   char username [64];  //  Username (if any) associated with conversation
////   char ticket [32];    //  Session ticket (for session-based services)
////   char client [32];    //  IP address of client that initiated conversation
////   UINT_32 origin;      //  Time of original connection (actually a 32-bit "time_t")
////   UINT_32 last;        //  Time of last connection (used for timeouts)
////   INT_32 timeout;      //  Number of seconds to keep ticket alive
////   char *hostname;      //  Name of this host, for building absolute URIs
////   char *uri;           //  The URI to process (if any)
////   UINT_32 retval;      //  HTTP response code for this command
////   UINT_32 retindex;    //  Index for response string for this command
////   UINT_32 fname_len;   //  Maximum length of "...fname" parameters
////   char *iw_fname;      //  File with body and headers of inbound connection
////   char *oh_fname;      //  File for headers for outbound reply
////   char *ob_fname;      //  File for body entity for outbound reply
////   char *oa_fname;      //  Alternate (static) file for outbound reply
////   UINT_32 o_parm_len;  //  Allocated length of following optional parameters
////   char *o_location;    //  Optional location to report for response file
////   char *o_ctype;       //  Optional content-type field for response file
////   UINT_32 port;        //  The TCP port on which the connection is operating
////   char *incookie;      //  Any cookie received from the connected client
////   char *outcookie;     //  Any cookie to return to the connected client
////   char *o_cdisp;       //  Any optional content-disposition header to return
////   } CONDEF;            //  CONversation DEFinition

type

  PServiceDef = ^TServiceDef;
  PCondef = ^TCondef;
  {$EXTERNALSYM _condef}
  _condef = packed record
    ssize: UINT_32;                       //  Size of this structure in bytes
    sversion: UINT_32;                    //  Version of this structure
    svc: PSERVICEDEF;                     //  Sub-service associated with this conversation
    data: UINTP;                          //  Sub-service specific data
    flags: UINT_32;                       //  MBCF_* flags for this command
    protocol: UINT_32;                    //  Protocol level of conversation - 9, 10 or 11
    method: UINT_32;                      //  Method used to submit this command
    mi: PM_INTERFACE;                     //  Mercury protocol module function block
    mbs: PMB_SERVICES;                    //  Useful utility functions for external subservices
    username: array[0..63] of AnsiChar;   //  Username (if any) associated with conversation
    ticket: array[0..31] of AnsiChar;     //  Session ticket (for session-based services)
    client: array[0..31] of AnsiChar;     //  IP address of client that initiated conversation
    origin: UINT_32;                      //  Time of original connection (actually a 32-bit "time_t")
    last: UINT_32;                        //  Time of last connection (used for timeouts)
    timeout: INT_32;                      //  Number of seconds to keep ticket alive
    hostname: PAnsiChar;                  //  Name of this host, for building absolute URIs
    uri: PAnsiChar;                       //  The URI to process (if any)
    retval: UINT_32;                      //  HTTP response code for this command
    retindex: UINT_32;                    //  Index for response string for this command
    fname_len: UINT_32;                   //  Maximum length of "...fname" parameters
    iw_fname: PAnsiChar;                  //  File with body and headers of inbound connection
    oh_fname: PAnsiChar;                  //  File for headers for outbound reply
    ob_fname: PAnsiChar;                  //  File for body entity for outbound reply
    oa_fname: PAnsiChar;                  //  Alternate (static) file for outbound reply
    o_parm_len: UINT_32;                  //  Allocated length of following optional parameters
    o_location: PAnsiChar;                //  Optional location to report for response file
    o_ctype: PAnsiChar;                   //  Optional content-type field for response file
    port: UINT_32;                        //  The TCP port on which the connection is operating
    incookie: PAnsiChar;                  //  Any cookie received from the connected client
    outcookie: PAnsiChar;                 //  Any cookie to return to the connected client
    o_cdisp: PAnsiChar;                  //  Any optional content-disposition header to return
  end;
  {$EXTERNALSYM CONDEF}
  CONDEF = _condef;
  TCondef = _condef;
  //  CONversation DEFinition

//  CONDEF = _condef;
////INT_32 MBHANDLER (CONDEF *cd, UINT_32 command, UINTP parm1, UINTP parm2);

{$EXTERNALSYM MBHANDLER}
  MBHANDLER = function (var cd: CONDEF; command: UINT_32; parm1: UINTP; parm2: UINTP): INT_32; cdecl;

  {$EXTERNALSYM SERVICEDEF}
  SERVICEDEF = packed record
    ServiceName: array[0..79] of AnsiChar;
    Flags: UINT_32;
    Handler: MBHANDLER;
    HLib: THandle; //HINSTANCE;
  end;
  TServicedef = SERVICEDEF;

//#ifdef __VISUALC__
//#pragma pack(pop)
//#endif
//
//#ifdef __cplusplus
//   //  Terminate "Extern C" block
//   }
//#endif
//
//#endif  //  _DAEMON_H_

implementation

end.



