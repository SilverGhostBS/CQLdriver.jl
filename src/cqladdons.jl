export PreparedStatement, Future, Result, Iterator, free, preparestatement

const PreparedStatement = Ptr{CQLdriver.CassStatement}
const Future = Ptr{CQLdriver.CassFuture}
const Result = Ptr{CQLdriver.CassResult}
const Iterator = Ptr{CQLdriver.CassIterator}

function free(statement::PreparedStatement)
    CQLdriver.cql_statement_free(statement)
end

function free(future::Future)
    CQLdriver.cql_future_free(future)
end

function free(result::Result)
    CQLdriver.cql_result_free(result)
end

function free(iterator::Iterator)
    CQLdriver.cql_iterator_free(iterator)
end

function preparestatement(query::AbstractString, nbparams::Integer; pgsize::Int=10000, timeout::Int=10000)::PreparedStatement
    statement = CQLdriver.cql_statement_new(query, nbparams)
    CQLdriver.cql_statement_set_request_timeout(statement, timeout)
    CQLdriver.cql_statement_set_paging_size(statement, pgsize)

    return statement
end

function preparestatement(f::Function, query::AbstractString, nbparams::Integer; pgsize::Int=10000, timeout::Int=10000)::PreparedStatement
    statement = CQLdriver.cql_statement_new(query, nbparams)
    CQLdriver.cql_statement_set_request_timeout(statement, timeout)
    CQLdriver.cql_statement_set_paging_size(statement, pgsize)
    try
        f(statement)
    finally
        free(statement)
    end
end
