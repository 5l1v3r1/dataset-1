#=
This is a experimental wrapper for Julia so we you use the Go based _dataset_ 
package developed at Caltech Library. 
=#


#
# This is just test code, when I get it working I should convert it to a Julia module/package.
#
import JSON

include("dataset.jl")
import dataset


#
# Setup our test collection, recreate it if necessary
#
function test_setup(collection_name::AbstractString)
    error_count = 0
    if isdir(collection_name) == true
        rm(collection_name, recursive=true)
    end
    ok = dataset.init(collection_name)
    if ok == false
        println("Failed, could not create collection")
        error_count += 1
        return error_count
    end
    error_count
end


function test_basic(collection_name::AbstractString)
    """test_basic(collection_name) runs tests on basic CRUD ops"""
    error_count = 0
    # Setup a test record
    key = "2488"
    value = JSON.parse("""{ "title": "Twenty Thousand Leagues Under the Seas: An Underwater Tour of the World", "formats": ["epub","kindle","plain text"], "authors": [{ "given": "Jules", "family": "Verne" }], "url": "https://www.gutenberg.org/ebooks/2488"}""")
    
    # We should have an empty collection, we will create our test record.
    ok = dataset.create(collection_name, key, value)
    if ok == false
        error_count += 1
        println("Failed, could not create record $key")
    end
    
    # Check to see that we have only one record
    key_count = dataset.count(collection_name)
    if key_count != 1
        error_count += 1
        println("Failed, expected count to be 1, got $key_count")
    end
    
    # Do a minimal test to see if the record looks like it has content
    keyList = dataset.keys(collection_name)
    rec = dataset.read(collection_name, key)
    for (k, v) in value
       if (isa(v, Dict{AbstractString,Any}) == false)
            if (haskey(rec, k) == true && rec[k] == v)
                println("OK, found ", k, " -> ", v)
            end
       else
            if (k == "formats" || k == "authors")
                println("OK, expected lists for $k -> $v")
            else
                println("Failed, expected $k with $v")
                error_count += 1
            end
        end
    end
    
    # Test updating record
    value["verified"] = true
    ok = dataset.update(collection_name, key, value)
    if (ok == false)
       println("Failed, count not update record $key -> $value")
       error_count += 1
    end
    rec = dataset.read(collection_name, key)
    for (k, v) in value
       if (isa(v, Dict{AbstractString, Any}) == false)
           if (haskey(rec,k) && rec[k] == v)
               println("OK, found $k -> $v")
           end
       else
           if (k == "formats" || k == "authors")
               println("OK, expected lists for $k -> $v")
           else
               println("Failed, expected $k with v, $v")
               error_count += 1
           end
        end
    end
    
    # Test path to record
    expected_s = "$collection_name/aa/$key.json"
    expected_l = length(expected_s)
    p = dataset.path(collection_name, key)
    if (length(p) != expected_l)
        println("Failed, expected length $expected_l got ", length(p))
        error_count += 1
    end
    if (p != expected_s)
        println("Failed, expected $expected_s got $p")
        error_count += 1
    end

    # Test listing records
    keys = [key::AbstractString]
    record_list = dataset.list(collection_name, keys)
    if (length(record_list) != 1)
        println("Failed, list should return an array of one record, got $l")
        error_count += 1
        return error_count
    end

    # test deleting a record
    ok = dataset.delete(collection_name, key)
    if (ok == false)
        println("Failed, could not delete record $key")
        error_count += 1
    end
    # test_basic() done
    if error_count > 0
        println("Test failed")
    end
    error_count
end


#
# test_keys(collection_name) test getting, filter and sorting keys
#
function test_keys(collection_name::AbstractString)
    """test_keys(collection_name) test getting, filter and sorting keys"""
    error_count = 0

    # Test count after delete
    key_list = dataset.keys(collection_name)
    cnt = dataset.count(collection_name)
    if cnt != 0
        println("Failed, expected zero records, got $cnt $key_list")
        error_count += 1
    end
    
    #
    # Generate multiple records for collection for testing keys and extract
    #
    test_records = JSON.parse("""{"gutenberg:21489": {"title": "The Secret of the Island", "formats": ["epub","kindle", "plain text", "html"], "authors": [{"given": "Jules", "family": "Verne"}], "url": "http://www.gutenberg.org/ebooks/21489", "categories": "fiction, novel"}, "gutenberg:2488": { "title": "Twenty Thousand Leagues Under the Seas: An Underwater Tour of the World", "formats": ["epub","kindle","plain text"], "authors": [{ "given": "Jules", "family": "Verne" }], "url": "https://www.gutenberg.org/ebooks/2488", "categories": "fiction, novel"}, "gutenberg:21839": { "title": "Sense and Sensibility", "formats": ["epub", "kindle", "plain text"], "authors": [{"given": "Jane", "family": "Austin"}], "url": "http://www.gutenberg.org/ebooks/21839", "categories": "fiction, novel" }, "gutenberg:3186": {"title": "The Mysterious Stranger, and Other Stories", "formats": ["epub","kindle", "plain text", "html"], "authors": [{ "given": "Mark", "family": "Twain"}], "url": "http://www.gutenberg.org/ebooks/3186", "categories": "fiction, short story"}, "hathi:uc1321060001561131": { "title": "A year of American travel - Narrative of personal experience", "formats": ["pdf"], "authors": [{"given": "Jessie Benton", "family": "Fremont"}], "url": "https://babel.hathitrust.org/cgi/pt?id=uc1.32106000561131&view=1up&seq=9", "categories": "non-fiction, memoir" } }""")

    test_count = length(test_records)
    
    for (k,v) in test_records
        ok = dataset.create(collection_name, k, v)
        if ok == false
            println("Failed, could not add $k to $collection_name")
            error_count += 1
        end 
    end
    # Test keys, filtering keys and sorting keys
    keys = dataset.keys(collection_name)
    if length(keys) != test_count
        println("Expected $test_count keys back, got $keys")
        error_count += 1
    end
    
    dataset.verbose_on()
    filter_expr = """(eq .categories "non-fiction, memoir")"""
    keys = dataset.keys(collection_name, filter_expr)
    if length(keys) != 1
        println("Expected one key for $filter_expr, got $keys")
        error_count += 1
    end
    
    filter_expr = """(contains .categories "novel")"""
    keys = dataset.keys(collection_name, filter_expr)
    if length(keys) != 3
        println("Expected three keys for $filter_expr, got $keys")
        error_count += 1
    end
    
    sort_expr = "+.title"
    filter_expr = """(contains .categories "novel")"""
    keys = dataset.keys(collection_name, filter_expr, sort_expr)
    if length(keys) != 3
        println("Expected three keys for $filter_expr  got $keys")
        error_count += 1
    end
    i = 1
    expected_keys = ["gutenberg:21839", "gutenberg:21489", "gutenberg:2488"]
    for k in expected_keys
        if (i < length(keys) && keys[i] != k)
            println("Expected $k got ", keys[i])
            error_count += 1
        end
        i += 1
    end

    # test_keys() done, return error count
    if error_count > 0
        println("Test failed")
    end
    error_count
end

    
#
# test_extract(collection_name) tests extracting unique values form a collection based on a dot path
#
function test_extract(collection_name)
    """test_extract() tests extracting unique values form a collection based on a dot path"""
    error_count = 0
    # Test extracting the family names
    v = dataset.extract(collection_name, "true", ".authors[:].family")
    if isa(v,Array{Any}) == false 
        println("Failed, expected a list, got ", typeof(v), v)
        error_count += 1
        return error_count
    end
    
    if length(v) != 4
        println("Failed expected list to be of length 4, got", length(v))
        error_count += 1
    end
    
    targets = [ "Austin", "Fremont", "Twain", "Verne" ]
    for s in targets
        if (s in v) == false
            println("Failed, expected to find ", s, " in ", v)
            error_count += 1
        end
    end
    # test_extract() done, return error count
    if error_count > 0
        println("Test failed")
    end
    error_count
end
    
#
# test_search(collection_name, index_map_name, index_name) tests indexer, deindexer and find funcitons
#
function test_search(collection_name, index_map_name, index_name)
    """test indexer, deindexer and find functions"""
    error_count = 0
    dataset.verbose_on()
    if isfile(index_name) == true
        rm(index_name, recursive = true)
    end
    if isfile(index_map_name) == true
        rm(index_map_name)
    end
    

    index_map_src = """{"title":{"object_path":".title"},"family":{"object_path":".authors[:].family"},"categories":{"object_path":".categories"}}"""
    index_map = JSON.parse(index_map_src)

    open(index_map_name, "w") do f
         write(f, index_map_src)
    end
    
    ok = dataset.indexer(collection_name, index_name, index_map_name, batch_size = 2)
    if (ok == false)
        println("Failed to index ", collection_name)
        error_count += 1
    end


    query_string = "+family:\"Verne\""
    results = dataset.find(index_name, query_string) 
    if (haskey(results, "total_hits") == true && results["total_hits"] != 2)
        println("Warning: unexpected results ", results)
    end
    hits = results["hits"]
    
    k1 = hits[1]["id"]
    ok = dataset.deindexer(collection_name, index_name, key_list = [k1], batch_size = 2)
    if ok == false
        println("deindexer failed for key ", k1)
    end

    # test_search(), done
    if error_count > 0
        println("Test failed")
    end
    error_count 
end


#
# test_issue32() make sure issue 32 stays fixed.
#
function test_issue32(collection_name)
    error_count = 0
    obj = JSON.parse("""{"one":1}""")
    ok = dataset.create(collection_name, "k1", obj)
    if ok == false
        println("Failed to create k1 in ", collection_name)
        error_count += 1
        return error_count
    end
    ok = dataset.has_key(collection_name, "k1")
    if ok == false
        println("Failed, has_key k1 should return ", true)
        error_count += 1
    end
    ok = dataset.has_key(collection_name, "k2")
    if ok == true
        println("Failed, has_key k2 should return ", false)
        error_count += 1
    end
    # test_issue32() done
    if error_count > 0
        println("Test failed")
    end
    error_count
end

    
#
# test_gsheet(collection_name, setup_bash), if setup_bash exists run Google Sheets tests.
#
function test_gsheet(collection_name, setup_bash)
    """if setup_bash exists, run Google Sheets tests"""
    if isfile(setup_bash) == false
        println("Skipping test_gsheet(", collection_name, ", ", setup_bash, ")")
        return 0
    end
    if isdir(collection_name)
        rm(collection_name, recursive = true)
    end
    error_count = 0
    cfg = Dict()
    # read the environment settings from fname, turn into object.
    open(setup_bash) do f
        for line in eachline(f)
            if contains(line, "export ") == true
                k,v = split(line[length("export ")+1:end],"=", limit = 2)
                k = lowercase(strip(k, '"'))
                v = strip(v, '"')
                cfg[k] = v
            end
        end
    end
    
    client_secret_name = ""
    sheet_id = ""
    if haskey(cfg,"client_secret_json") == false
        println("Failed, could not parse CLIENT_SECRET_JSON in ", setup_bash, cfg)
        error_count += 1
        return error_count
    else
        client_secret_name = cfg["client_secret_json"]
    end

    if haskey(cfg,"spreadsheet_id") == false
        println("Failed, could not parse SPREADSHEET_ID in ", setup_bash)
        error_count += 1
        return error_count
    else
        sheet_id = cfg["spreadsheet_id"]
    end
    client_secret_name = "../$client_secret_name"

    ok = dataset.init(collection_name)
    if ok == false
        println("Failed, could not create collection")
        error_count += 1
        return error_count
    end

    cnt = dataset.count(collection_name)
    if cnt != 0
        println("Failed to initialize a fresh collection ", collection_name)
        error_count += 1
        return error_count
    end

    # Setup some test data to work with.
    ok = dataset.create(collection_name, "Wilson1930","""{"additional":"Supplemental Files Information:\nGeologic Plate: Supplement 1 from \"The geology of a portion of the Repetto Hills\" (Thesis)\n","description_1":"Supplement 1 in CaltechDATA: Geologic Plate","done":"yes","identifier_1":"https://doi.org/10.22002/D1.638","key":"Wilson1930","resolver":"http://resolver.caltech.edu/CaltechTHESIS:12032009-111148185","subjects":"Repetto Hills, Coyote Pass, sandstones, shales"}""")
    if ok != true
        println("Failed, could not create test record in ", collection_name)
        error_count += 1
        return error_count
    end
    
    cnt = dataset.count(collection_name)
    if cnt != 1
        println("Failed, should have one test record in ", collection_name)
        error_count += 1
        return error_count
    end

    sheet_name = "Sheet1"
    cell_range = "A1:Z"
    filter_expr = "true"
    dot_exprs = [".done",".key",".resolver",".subjects",".additional",".identifier_1",".description_1"]
    column_names = ["Done","Key","Resolver","Subjects","Additional","Identifier 1","Description 1"]
    println("Testing gsheet export support ", sheet_id, sheet_name, cell_range, filter_expr, dot_exprs, column_names)
    ok = dataset.export_gsheet(collection_name, client_secret_name, sheet_id, sheet_name, cell_range, filter_expr, dot_exprs, column_names)
    if ok != true
        println("Failed, count not export-gsheet in", collection_name)
        error_count += 1
        return error_count
    end

    println("Testing gsheet import support (should fail)", sheet_id, sheet_name, cell_range, 2, false)
    dataset.verbose_off()
    ok = dataset.import_gsheet(collection_name, client_secret_name, sheet_id, sheet_name, cell_range, id_col = 2, overwrite = false)
    if ok == true
        println("Failed, should NOT be able to import-gsheet over our existing collection without overwrite = true")
        error_count += 1
        return error_count
    end

    println("Testing gsheet import support (should succeeed) ", sheet_id, sheet_name, cell_range, 2, true)
    ok = dataset.import_gsheet(collection_name, client_secret_name, sheet_id, sheet_name, cell_range, id_col = 2, overwrite = true) 
    if ok == false
        println("Failed, should be able to import-gsheet over our existing collection with overwrite=true")
        error_count += 1
        return error_count
    end

    # Check to see if this throws error correctly, i.e. should have exit code 1
    sheet_name="Sheet2"
    dot_exprs = ["true",".done",".key",".QT_resolver",".subjects",".additional[]",".identifier_1",".description_1"]
    ok = dataset.export_gsheet(collection_name, client_secret_name, sheet_id, sheet_name, cell_range, filter_expr, dot_exprs = dot_exprs)
    if ok == true
        println("Failed, export_gsheet should throw error for bad dotpath in export_gsheet")
        error_count += 1
        return error_count
    end

    # test_gsheet() done
    error_count
end

function test_check_repair(collection_name)
    error_count = 0
    println("Testing status on ", collection_name)
    # Make sure we have a left over collection to check and repair
    if isdir(collection_name) == false
        dataset.init(collection_name)
    end
    ok = dataset.status(collection_name)
    if ok == false
        println("Failed, expected dataset.status() == true, got ", ok, " for ", collection_name)
        error_count += 1
        return error_count
    end

    println("Testing check on ", collection_name)
    # Check our collection
    ok = dataset.check(collection_name)
    if ok == false
        println("Failed, expected check ", collection_name, " to return true, got ", ok)
        error_count += 1
    end

    # Break and recheck our collection
    if isfile("$collection_name/collection.json")
        rm("$collection_name/collection.json")
    end
    println("Testing check on (broken)", collection_name)
    ok = dataset.check(collection_name)
    if ok == true
        println("Failed, expected check ", collection_name, " to return false, got ", ok)
        error_count += 1
    end

    # Repair our collection
    println("Testing repair on ", collection_name)
    ok = dataset.repair(collection_name)
    if ok == false
        println("Failed, expected repair to return true, got ", ok)
        error_count += 1
    end
    error_count
end
        
function test_attachments(collection_name)
    println("Testing attach, attachments, detach and prune")
    # Generate two files to attach.
    open("a1.txt", "w") do f
        write(f, "This is file a1")
    end
    open("a2.txt", "w") do f
        write(f, "This is file a2")
    end
    filenames = ["a1.txt","a2.txt"]

    error_count = 0
    ok = dataset.status(collection_name)
    if ok == false
        println("Failed, ", collection_name, " missing")
        error_count += 1
        return error_count
    end
    keys = dataset.keys(collection_name)
    if length(keys) < 1
        println("Failed, ", collection_name, " should have keys")
        error_count += 1
        return error_count
    end

    key = keys[1]
    ok = dataset.attach(collection_name, key, filenames)
    if ok == false
        println("Failed, to attach files for ", collection_name, ", ", key, ", ", filenames)
        error_count += 1
        return error_count
    end

    l = dataset.attachments(collection_name, key)
    if length(l) != 2
        println("Failed, expected two attachments for ", collection_name, ", ", key, " got ", l)
        error_count += 1
        return error_count
    end

    if isfile(filenames[1])
        rm(filenames[1])
    end
    if isfile(filenames[2])
        rm(filenames[2])
    end

    # First try detaching one file.
    ok = dataset.detach(collection_name, key, filenames = [filenames[1]])
    if ok == false
        println("Failed, expected true for ", collection_name, ", ", key, ", ", filenames[1])
        error_count += 1
    end
    if isfile(filenames[1])
        rm(filenames[1])
    else
        printf("Failed to detch ", filenames[1], " from ", collection_name, ", ", key)
        error_count += 1
    end

    # Test explicit filenames detch
    ok = dataset.detach(collection_name, key, filenames = filenames)
    if ok == false
        println("Failed, expected true for ", collection_name, ", ", key, ", ", filenames)
        error_count += 1 
    end

    for fname in filenames
        if isfile(fname)
            rm(fname)
        else
            println("Failed, expected ", fname, " to be detached from ", collection_name, ", ", key)
            error_count += 1
        end
    end

    # Test detaching all files
    ok = dataset.detach(collection_name, key)
    if ok == false
        println("Failed, expected true for (detaching all) ", collection_name, ", ", key)
        error_count += 1 
    end
    for fname in filenames
        if isfile(fname)
            rm(fname)
        else
            println("Failed, expected ", fname, " for detaching all from ", collection_name, ", ", key)
            error_count += 1
        end
    end

    ok = dataset.prune(collection_name, key, filenames = [filenames[1]])
    if ok == false
        println("Failed, expected true for prune ", collection_name, ", ", key, ", ", [filenames[1]])
        error_count += 1 
    end
    l = dataset.attachments(collection_name, key)
    if length(l) != 1
        println("Failed, expected one file after prune for ", collection_name, ", ", key, ", ", [filenames[1]], " got ", l)
        error_count += 1
    end

    ok = dataset.prune(collection_name, key)
    if ok == false
        println("Failed, expected true for prune (all) ", collection_name, ", ", key)
        error_count += 1 
    end
    l = dataset.attachments(collection_name, key)
    if length(l) != 0
        println("Failed, expected zero files after prune for ", collection_name, ", ", key, " got ", l)
        error_count += 1
    end
    error_count
end

function test_s3()
    error_count = 0
    if (haskey(ENV, "AWS_SDK_LOAD_CONFIG") == false || haskey(ENV, "DATASET") == false)
        println("Skipping test_s3(), missing environment AWS_SDK_LOAD_CONFIG and DATASET")
        return error_count
    end
    aws_sdk_load_config = ENV["AWS_SDK_LOAD_CONFIG"]
    collection_name = ENV["DATASET"]
    if (aws_sdk_load_config != "1" || collection_name[0:5] != "s3://")
        println("Skipping test_s3(), AWS_SDK_LOAD_CONFIG != 1 or DATASET is not s3://")
        return error_count
    end
    
    ok = dataset.status(collection_name)
    if ok == false
        println("Missing ", collection_name, " attempting to initialize ", collection_name)
        ok = dataset.init(collection_name)
        if ok == false
            println("Aborting, couldn't initialize ", collection_name)
            error_count += 1
            return error_count
        end
    else
        println("Using collection initialized as ", collection_name)
    end

    collection_name = os.getenv("DATASET")
    record = JSON.parse("""{ "one": 1 }""")
    key = "s3t1"
    ok = dataset.create(collection_name, key, record)
    if ok == false
        println("Failed to create record ", collection_name, ", ", key, ", ", record)
        error_count += 1
    end
    record2 = dataset.read(collection_name, key)
    if record2["one"] != 1
        println("Failed, read ", collection_name, ", ", key, ", ", record2)
        error_count += 1
    end
    record["two"] = 2
    ok = dataset.update(collection_name, key, record)
    if ok == false
        println("Failed to update record ", collection_name, ", ", key, ", ", record)
        error_count += 1
    end
    record2 = dataset.read(collection_name, key)
    if record2["one"] != 1
        println("Failed, 2nd read ", collection_name, ", ", key, ", ", record2)
        error_count += 1
    end
    if record2["two"] != 2
        println("Failed, 2nd read ", collection_name, ", ", key, ", ", record2)
        error_count += 1
    end
    ok = dataset.delete(collection_name, key)
    if ok == false
        println("Failed to delete record ", collection_name, ", ", key, ", ", record)
        error_count += 1
    end
    ok = dataset.has_key(collection_name, key)
    if ok == true
        println("Failed, delete should have removed key ", collection_name, key)
        error_count += 1
    end
    error_count     
end

function test_join(collection_name)
    error_count = 0
    key = "test_join1"
    obj1 = JSON.parse("""{ "one": 1}""")
    obj2 = JSON.parse("""{ "two": 2}""")
    ok = dataset.status(collection_name)
    if ok == false
        println("Failed, collection status is false, ", collection_name)
        error_count += 1
        return error_count
    end
    ok = dataset.has_key(collection_name, key)
    if ok == true
        ok = dataset.update(collection_nane, key, obj1)
    else
        ok = dataset.create(collection_name, key, obj1)
    end
    if ok == false
        println("Failed, could not add record for test ", collection, ", ", key, ", ", obj1)
        error_count += 1
        return error_count
    end

    ok = dataset.join(collection_name, key, "append", obj2)
    if ok == false
        println("Failed, join for ", collection_name, key, " append ", obj2)
        error_count += 1
    end
    obj_result = dataset.read(collection_name, key)
    if (obj_result["one"] != 1)
        println("Failed to join append key ", key, ", ", obj_result)
        error_count += 1
    end
    if (obj_result["two"] != 2)
        println("Failed to join append key ", key, ", ", obj_result)
        error_count += 1
    end
    obj2["one"] = 3
    obj2["two"] = 3
    obj2["three"] = 3
    ok = dataset.join(collection_name, key, "overwrite", obj2)
    if ok == false
        println("Failed to join overwrite ", collection_name, key, " overwrite ", obj2)
        error_count += 1
    end
    obj_result = dataset.read(collection_name, key)
    for (k,v) in obj_result
        if (k != "_Key" && v != 3)
            println("Failed to update value in join overwrite ", k, obj_result)
            error_count += 1
        end
    end

    ok = dataset.join(collection_name, key, "fred and mary", obj2)
    if ok == true
        println("Failed, expected error for join type 'fred and mary'")
        error_count += 1
    end
    error_count
end

#
# Main processing
#
println("Testing dataset.jl version ", dataset.version())

# Pre-test check
error_count = 0
ok = true
dataset.verbose_off()

collection_name = "test_collection.ds"
ok = dataset.init(collection_name)
(ok == true) ? true : (println("Failed to create test collection ", collection_name);exit(1))

error_count += test_setup(collection_name)
error_count += test_basic(collection_name)
error_count += test_keys(collection_name)
error_count += test_extract(collection_name)
error_count += test_search(collection_name, "test_index_map.json", "test_index.bleve")
error_count += test_issue32(collection_name)
error_count += test_attachments(collection_name)
error_count += test_join(collection_name)
error_count += test_check_repair("test_check_and_repair.ds")
#FIXME: Need to check if GSheet access is setup, otherwise skip with warning
error_count += test_gsheet("test_gsheet.ds", "../etc/test_gsheet.bash")

#=
error_count += test_s3()
=#

println("Tests completed")

# Summarize our test results
if error_count > 0
    println("Total errors ", error_count)
    exit(1)
end
println("PASS")
println("OK, dataset_test.jl")


