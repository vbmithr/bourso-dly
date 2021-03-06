open Core.Std

let ocs = String.Table.create ()

let fix_date date_str =
  match String.split ~on:'/' date_str with
  | [day; month; year] -> year ^ month ^ day
  | _ -> invalid_arg "fix_date"

let fn_of_label label =
  let to_replace = [' '; '\''; '('; ')'; ':'; '/'] in
  List.iter to_replace ~f:(fun target ->
      String.tr_inplace ~target ~replacement:'_' label);
  label ^ ".dly"

let process_bourso_line ?(overwrite=false) line =
  match String.split ~on:'\t' line with
  | [label; date; open'; high; low; close; vol] -> begin
      let label = fn_of_label label in
      let oc =
        match String.Table.find ocs label with
        | Some oc -> oc
        | None ->
          let oc = Out_channel.create ~binary:false ~append:(not overwrite) label in
          String.Table.add_exn ocs ~key:label ~data:oc;
          oc
      in
      Printf.fprintf oc "%s,%s,%s,%s,%s,%s\n" (fix_date date) open' high low close vol
    end
  | _ -> Printf.eprintf "invalid line: %s\n" line

let command =
  let spec =
    let open Command.Spec in
    empty
    +> flag "-overwrite" no_arg ~doc:" Overwrite files"
    +> anon ("filename" %: string)
    +> anon ("dirname" %: string)
  in
  let main overwrite fn dn () =
    let rec process_line ic =
      match In_channel.input_line ic with
      | None ->
        String.Table.iteri ocs ~f:(fun ~key ~data -> Out_channel.close data)
      | Some line ->
        process_bourso_line ~overwrite line;
        process_line ic
    in
    Unix.mkdir_p dn;
    Sys.chdir dn;
    In_channel.with_file ~binary:false fn ~f:process_line
  in
  Command.basic ~summary:"Convert bourso dly file into SC dly files" spec main

let () = Command.run command
