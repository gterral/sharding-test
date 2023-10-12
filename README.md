# README

Steps to reproduce:

1. Initialize app 
```shell 
rails new sharding-test --database=postgresql
cd sharding-test 
``

2. Update `database.yml`
```yml 
  primary: 
    <<: *default
    database: primary
  primary_replica:
    <<: *default
    database: primary
    replica: true
  first_shard: 
    <<: *default
    database: first_shard
  first_shard_replica:
    <<: *default
    database: first_shard
    replica: true
  second_shard: 
    <<: *default
    database: second_shard
  second_shard_replica:
    <<: *default
    database: second_shard
    replica: true
```

3. Run `bin/rails db:create`
It should create 4 databases
```shell 
Created database 'primary'
Created database 'first_shard'
Created database 'second_shard'
Created database 'sharding_test_test'
```

4. Create a new model called Invoice
```shell 
  rails g model Invoice label:string
```

5. Update application record
```rb
  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    first_shard: { writing: :first_shard, reading: :first_shard_replica },
    second_shard: { writing: :second_shard, reading: :second_shard_replica },
  }
```
6. Run `bin/rails db:migrate`
Note that it runs the migration on all database! 

7. Update seeds.rb and run `bin/rails db:seed`

Invoice.create!([{label: 'Invoice A'}, { label: 'Invoice B'}])

8. Have a look at the database
```shell 
psql primary 
```

```psql
\l

\c primary;
SELECT * from invoices; 
-- Both invoices are here

/c first_shard;
-- No invoices

/c second_shard;
-- No invoices
``````

10. Open a rails console and play with the multiple database and see the magic

```rb 
ActiveRecord::Base.connected_to(role: :reading, shard: :first_shard) do
  Invoice.first
end 

ActiveRecord::Base.connected_to(role: :writing, shard: :first_shard) do
  Invoice.create!(label: 'Invoice C')
end 
```