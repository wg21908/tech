#
# Copyright (c) 1998, 1999 Proofpoint, Inc. and its suppliers.
#	All rights reserved.
# Copyright (c) 1983 Eric P. Allman.  All rights reserved.
# Copyright (c) 1988, 1993
#	The Regents of the University of California.  All rights reserved.
#
# By using this file, you agree to the terms and conditions set
# forth in the LICENSE file which can be found at the top level of
# the sendmail distribution.
#
#

#
#  This is a generic configuration file for Linux.
#  It has support for local and SMTP mail only.  If you want to
#  customize it, copy it to a name appropriate for your environment
#  and do the modifications there.
#

divert(-1)
include(`/etc/mail/m4/cf.m4')dnl
VERSIONID(`sendmail with Gmail relay')
OSTYPE(`linux')dnl
define(`SMART_HOST', `[smtp.gmail.com]:587')dnl
define(`RELAY_MAILER_ARGS', `TCP $h 587')dnl
define(`ESMTP_MAILER_ARGS', `TCP $h 587')dnl
FEATURE(`authinfo', `hash -o /etc/mail/authinfo.db')dnl
FEATURE(`use_ct_file')dnl
MAILER(local)dnl
MAILER(smtp)dnl

