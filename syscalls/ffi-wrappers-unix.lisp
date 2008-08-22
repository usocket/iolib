;;;; -*- Mode: Lisp; Syntax: ANSI-Common-Lisp; indent-tabs-mode: nil -*-
;;;
;;; --- FFI wrappers.
;;;

(in-package :iolib.syscalls)

(c "#if defined(__linux__)")
(define "_XOPEN_SOURCE" 600)
(define "_LARGEFILE_SOURCE")
(define "_LARGEFILE64_SOURCE")
(define "_FILE_OFFSET_BITS" 64)
(c "#endif")

(include "string.h" "errno.h" "sys/types.h" "sys/stat.h"
         "unistd.h" "sys/mman.h")


;;;-----------------------------------------------------------------------------
;;; Large-file support
;;;-----------------------------------------------------------------------------

;;; FIXME: this is only necessary on Linux right?

(defwrapper ("lseek" %sys-lseek)
    ("off_t" off-t)
  (fildes ("int" :int))
  (offset ("off_t" off-t))
  (whence :int))

(defwrapper ("truncate" %sys-truncate)
    ("int" (return-wrapper :int :error-generator return-posix-error/restart))
  (path ("const char*" filename-designator))
  (length ("off_t" off-t)))

(defwrapper ("ftruncate" %sys-ftruncate)
    ("int" (return-wrapper :int :error-generator return-posix-error/restart))
  (fd ("int" :int))
  (length ("off_t" off-t)))

(defwrapper ("mmap" %sys-mmap)
    ("void*" :pointer)
  (start :pointer)
  (length ("size_t" size-t))
  (prot :int)
  (flags :int)
  (fd ("int" :int))
  (offset ("off_t" off-t)))

(defwrapper ("stat" %%sys-stat)
    ("int" :int)
  (file-name ("const char*" filename-designator))
  (buf ("struct stat*" :pointer)))

(defwrapper ("fstat" %%sys-fstat)
    ("int" :int)
  (filedes ("int" :int))
  (buf ("struct stat*" :pointer)))

(defwrapper ("lstat" %%sys-lstat)
    ("int" :int)
  (file-name ("const char*" filename-designator))
  (buf ("struct stat*" :pointer)))

(defwrapper ("pread" %sys-pread)
    ("ssize_t" (return-wrapper ssize-t :error-generator return-posix-error/restart))
  (fd ("int" :int))
  (buf :pointer)
  (count ("size_t" size-t))
  (offset ("off_t" off-t)))

(defwrapper ("pwrite" %sys-pwrite)
    ("ssize_t" (return-wrapper ssize-t :error-generator return-posix-error/restart))
  (fd ("int" :int))
  (buf :pointer)
  (count ("size_t" size-t))
  (offset ("off_t" off-t)))


;;;-----------------------------------------------------------------------------
;;; ERRNO-related functions
;;;-----------------------------------------------------------------------------

(defwrapper* "get_errno" :int ()
  "return errno;")

(defwrapper* "set_errno" :int ((value :int))
  "errno = value;"
  "return errno;")

(defwrapper ("strerror_r" %sys-strerror-r)
    :int
  (errnum :int)
  (buf :string)
  (buflen ("size_t" size-t)))
