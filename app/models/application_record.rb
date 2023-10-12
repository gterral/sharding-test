class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to shards: {
    default: { writing: :primary, reading: :primary_replica },
    first_shard: { writing: :first_shard, reading: :first_shard_replica },
    second_shard: { writing: :second_shard, reading: :second_shard_replica },
  }
end
