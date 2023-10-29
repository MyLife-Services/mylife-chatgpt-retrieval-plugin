-- init.sql
CREATE EXTENSION IF NOT EXISTS vector;

create table if not exists mylife_documents (
    id text primary key default gen_random_uuid()::text,
    source text default 'file',
    source_id text,
    content text,
    document_id text,
    author text,
    url text,
    created_at timestamptz default now(),
    embedding vector(1536)
);

create index ix_documents_document_id on mylife_documents using btree ( document_id );
create index ix_documents_source on mylife_documents using btree ( source );
create index ix_documents_source_id on mylife_documents using btree ( source_id );
create index ix_documents_author on mylife_documents using btree ( author );
create index ix_documents_created_at on mylife_documents using brin ( created_at );

alter table mylife_documents enable row level security;

create or replace function match_page_sections(in_embedding vector(1536)
                                            , in_match_count int default 3
                                            , in_document_id text default '%%'
                                            , in_source_id text default '%%'
                                            , in_source text default '%%'
                                            , in_author text default '%%'
                                            , in_start_date timestamptz default '-infinity'
                                            , in_end_date timestamptz default 'infinity')
returns table (id text
            , source text
            , source_id text
            , document_id text
            , url text
            , created_at timestamptz
            , author text
            , content text
            , embedding vector(1536)
            , similarity float)
language plpgsql
as $$
#variable_conflict use_variable
begin
return query
select
    mylife_documents.id,
    mylife_documents.source,
    mylife_documents.source_id,
    mylife_documents.document_id,
    mylife_documents.url,
    mylife_documents.created_at,
    mylife_documents.author,
    mylife_documents.content,
    mylife_documents.embedding,
    (mylife_documents.embedding <#> in_embedding) * -1 as similarity
from mylife_documents

where in_start_date <= mylife_documents.created_at and 
    mylife_documents.created_at <= in_end_date and
    (mylife_documents.source_id like in_source_id or mylife_documents.source_id is null) and
    (mylife_documents.source like in_source or mylife_documents.source is null) and
    (mylife_documents.author like in_author or mylife_documents.author is null) and
    (mylife_documents.document_id like in_document_id or mylife_documents.document_id is null)

order by mylife_documents.embedding <#> in_embedding

limit in_match_count;
end;
$$;