(**
 * Copyright (c) 2015, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the "hack" directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *
 *)

(** If a worker process fails, this is raised.
 *
 * Note: When one worker process fails, the remaining in-progress workers are checked
 * for completion/failure, and all their failures (non-zero exit code) are coalesced
 * together into one of these exceptions.
 *
 * No further buckets are distributed to workers.
 *
 * Still-in-progress workers are left to their own accord. *)
exception Coalesced_failures of (WorkerController.worker_failure list)

type interrupt_result = Cancel | Continue

type 'env interrupt_handler =
  'env -> Unix.file_descr list -> 'env * interrupt_result

type 'env interrupt_config = {
  fds : Unix.file_descr list;
  env : 'env;
  handler : 'env interrupt_handler;
}

val no_interrupt : 'a -> 'a interrupt_config

(** Can raise Coalesced_failures exception. *)
val call :
  WorkerController.worker list ->
  ('c -> 'a -> 'b) ->
  ('b -> 'c -> 'c) ->
  'c ->
  'a Bucket.next ->
  'c

val call_with_interrupt :
  WorkerController.worker list ->
  ('c -> 'a -> 'b) ->
  ('b -> 'c -> 'c) -> 'c ->
  'a Bucket.next ->
  'd interrupt_config ->
  'c * 'd * 'a list
