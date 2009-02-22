module TW
  module ConfigureTable
    def self.included(base) # :nodoc:
      base.send(:include, InstanceMethods)
    end

    module InstanceMethods
      def myisam(tablename = false)
        execute "ALTER TABLE " + tablename + " ENGINE=MyISAM" if tablename
      end
    end
  end
  
  module MigrationHelper
     def self.included(base) # :nodoc:
       base.send(:include, InstanceMethods)
     end
     
     module InstanceMethods
        def userstamps(include_deleted_by = false)
          column(Ddb::Userstamp.compatibility_mode ? :created_by : :creator_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :updated_by : :updater_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :deleted_by : :deleter_id, :integer) if include_deleted_by
        end
     
        def archiveable
          column(:deleted_at, :datetime)
        end
     
        def usesguid(fieldlimit=22)
          column :id, :string, :limit => fieldlimit
        end
      end
  end
end

ActiveRecord::ConnectionAdapters::MysqlAdapter.send(:include, TW::ConfigureTable)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, TW::MigrationHelper)