#=
dataset.jl provides a module wrapper around Caltech Library Golang based dataset.
=#

module dataset

import JSON

export is_verbose, verbose_on, verbose_off, version, init, has_key, create, read, update, delete, keys, key_filter, key_sort, count, extract, indexer, deindexer, find, import_csv, export_csv, import_gsheet, export_gsheet, status, list, path, check, repair, attach, attachments, detach, prune


function is_verbose()
    ok = ccall((:is_verbose, "./libdataset"), Int32, (),)
    (ok != 0)
end

function verbose_on()
    ccall((:verbose_on, "./libdataset"), Int32, (),)
    is_verbose()
end

function verbose_off()
    ccall((:verbose_off, "./libdataset"), Int32, (),)
    is_verbose()
end

function version()
    value = ccall((:version, "./libdataset"), Cstring, (),)
    convert(UTF8String, bytestring(value))
end

function init(collection_name::AbstractString)
    ok = ccall((:init_collection, "./libdataset"), Int32, (Cstring,), collection_name)
    (ok == 1)
end

function has_key(collection_name::AbstractString, key::AbstractString)
    ok = ccall((:has_key, "./libdataset"), Int32, (Cstring, Cstring), collection_name, key)
    (ok == 1)
end

function create(collection_name::AbstractString, key::AbstractString, data)
    src = JSON.json(data)
    ok = ccall((:create_record, "./libdataset"), Int32, (Cstring, Cstring, Cstring), collection_name, key, src)
    (ok == 1)
end

function read(collection_name::AbstractString, key::AbstractString)
    value = ccall((:read_record, "./libdataset"), Cstring, (Cstring, Cstring), collection_name, key)
    src = convert(UTF8String,bytestring(value))
    JSON.parse(src)
end

function update(collection_name::AbstractString, key::AbstractString, data)
    src = JSON.json(data)
    ok = ccall((:update_record, "./libdataset"), Int32, (Cstring, Cstring, Cstring), collection_name, key, src)
    (ok == 1)
end

function delete(collection_name::AbstractString, key::AbstractString)
    ok = ccall((:delete_record, "./libdataset"), Int32, (Cstring, Cstring), collection_name, key)
    (ok == 1)
end

function keys(collection_name::AbstractString, filter_expr::AbstractString = "", sort_expr::AbstractString = "")
    value = ccall((:keys, "./libdataset"), Cstring, (Cstring, Cstring, Cstring), collection_name, filter_expr, sort_expr)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

function key_filter(collection_name::AbstractString, key_list::Array{AbstractString,1}, filter_expr::AbstractString)
    src = JSON.json(key_list)
    value = ccall((:key_filter, "./libdataset"), Cstring, (Cstring, Cstring, Cstring, Cstring), collection_name, keys_src, filter_expr)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

function key_sort(collection_name::AbstractString, key_list::Array{AbstractString,1}, sort_expr::AbstractString)
    src = JSON.json(key_list)
    value = ccall((:key_sort, "./libdataset"), Cstring, (Cstring, Cstring, Cstring, Cstring), collection_name, keys_src, sort_expr)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

function count(collection_name::AbstractString)
    ccall((:count, "./libdataset"), Int32, (Cstring,), collection_name)
end

function extract(collection_name::AbstractString, filter_expr::AbstractString, dot_expr::AbstractString)
    value = ccall((:extract, "./libdataset"), Cstring, (Cstring, Cstring, Cstring), collection_name, filter_expr, dot_expr)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

# NOTE: switching key_list to Array{Any,1} from Array{AbstrastString,1}
function indexer(collection_name::AbstractString, index_name::AbstractString, index_map_name::AbstractString; key_list = [], batch_size = 1000)
    src_key_list = JSON.json(key_list)
    ok = ccall((:indexer, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Cstring, Int32,), collection_name, index_name, index_map_name, src_key_list, batch_size)
    (ok == 1)
end

function deindexer(collection_name::AbstractString, index_name::AbstractString; key_list = [], batch_size = 1000)
    src_key_list = JSON.json(key_list)
    ok = ccall((:deindexer, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Int32), collection_name, index_name, src_key_list, batch_size)
    (ok == 1)
end

function find(index_name::AbstractString, query_string::AbstractString; options = Dict()) #::Dict{Any,Any})
    src_options = JSON.json(options)
    value = ccall((:find, "./libdataset"), Cstring, (Cstring, Cstring, Cstring), index_name, query_string, src_options)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

function import_csv(collection_name::AbstractString, CSV_name::AbstractString, id_col::Int32, use_header_row::Bool, use_uuid::Bool, overwrite::Bool)
    use_header_row == true ? i_use_header_row = 1 : i_user_header_row = 0
    use_uuid == true ? i_use_uuid = 1 : i_use_uuid = 0
    overwrite == true ? i_overwrite = 1 : i_overwrite = 0
    ok = ccall((:import_csv, "./libdataset"), Int32, (Cstring, Cstring, Int32, Int32, Int32, Int32), collection_name, CSV_name, id_col, i_use_header_row, i_use_uuid, i_overwrite)
    (ok == 1) 
end

function export_csv(collection_name::AbstractString, CSV_name::AbstractString, filter_expr::AbstractString, dot_expr::AbstractString, col_names::Array{AbstractString, 1})
    src_col_names = JSON.json(col_names)
    ok = ccall((:export_csv, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Cstring, Cstring), collection_name, CSV_name, filter_expr, dot_expr, src_col_names)
    (ok == 1)
end

function import_gsheet(collection_name::AbstractString, client_secret_name::AbstractString, sheet_id::AbstractString, sheet_name::AbstractString, cell_range::AbstractString, id_col::Int32, use_header_row::Bool, use_uuid::Bool, overwrite::Bool)
    use_header_row == true ? i_use_header_row = 1 : i_user_header_row = 0
    use_uuid == true ? i_use_uuid = 1 : i_use_uuid = 0
    overwrite == true ? i_overwrite = 1 : i_overwrite = 0
    ok = ccall((:import_gsheet, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Cstring, Cstring, Int32, Int32, Int32, Int32), collection_name, client_secret_name, sheet_id, sheet_name, cell_range, id_col, i_use_header_row, i_use_uuid, i_overwrite)
    (ok == 1)
end


function export_gsheet(collection_name::AbstractString, client_secret_name::AbstractString, sheet_id::AbstractString, sheet_name::AbstractString, cell_range::AbstractString, filter_expr::AbstractString, dot_exprs::AbstractString, col_names::Array{AbstractString,1})
    src_col_names = JSON.json(col_names)
    ok = ccall((:export_gsheet, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Cstring, Cstring, Cstring, Cstring, Cstring), collection_name, client_secret_name, sheet_id, sheet_name, cell_range, filter_expr, dot_exprs, src_col_names)
    (ok == 1)
end

function status(collection_name::AbstractString)
    ok = ccall((:status, "./libdataset"), Int32, (Cstring,), collection_name)
    (ok == 1)
end


#NOTE: keys::Array{AbstractString,1} seems to cause allot of type errors, stilling to keys as untyped until I know what is going on in Julia better
function list(collection_name::AbstractString, keys)
    src_keys = JSON.json(keys)
    value = ccall((:list, "./libdataset"), Cstring, (Cstring, Cstring), collection_name, src_keys)
    src = convert(UTF8String, bytestring(value))
    JSON.parse(src)
end

function join(collection_name::AbstractString, key::AbstractString, adverb::AbstractString, obj)
    src = JSON.json(obj)
    ok = ccall((:join, "./libdataset"), Int32, (Cstring, Cstring, Cstring, Cstring), collection_name, key, adverb, src)
    (ok == 1)
end

function path(collection_name::AbstractString, key::AbstractString)
    value = ccall((:path, "./libdataset"), Cstring, (Cstring, Cstring), collection_name, key)
    src = convert(UTF8String, bytestring(value))
    src
end

function check(collection_name::AbstractString)
    ok = ccall((:check, "./libdataset"), Int32, (Cstring,), collection_name)
    (ok == 1)
end

function repair(collection_name::AbstractString)
    ok = ccall((:repair, "./libdataset"), Int32, (Cstring,), collection_name)
    (ok == 1)
end


function attach(collection_name::AbstractString, key::AbstractString, filenames = [])
    src_filenames = JSON.json(filenames)
    ok = ccall((:attach, "./libdataset"), Int32, (Cstring, Cstring, Cstring), collection_name, key, src_filenames)
    (ok == 1)
end

function attachments(collection_name::AbstractString, key::AbstractString)
    value = ccall((:attachments, "./libdataset"), Cstring, (Cstring, Cstring), collection_name, key)
    src = convert(UTF8String, bytestring(value))
    if length(src) == 0
        return []
    end
    split(src, "\n")
end

function detach(collection_name::AbstractString, key::AbstractString; filenames = [])
    src_filenames = JSON.json(filenames)
    ok = ccall((:detach, "./libdataset"), Int32, (Cstring, Cstring, Cstring), collection_name, key, src_filenames)
    (ok == 1)
end

function prune(collection_name::AbstractString, key::AbstractString; filenames = [])
    src_filenames = JSON.json(filenames)
    ok = ccall((:prune, "./libdataset"), Int32, (Cstring, Cstring, Cstring), collection_name, key, src_filenames)
    (ok == 1)
end

end
