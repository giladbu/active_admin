module ActiveAdmin
  class ResourceTracker
    def initialize
      @mtimes = {}
    end

    def changed?(path)
      return true if path =~ /dashboard/

      file_mtime = File.mtime(path)
      if !@mtimes.has_key?(path) 
        changed = true
      else
        changed = @mtimes[path] != file_mtime
      end
      @mtimes[path] = file_mtime
      changed
    end

    def unload? (resource)
      #active_admin comments registers once, so dont unload
      return false if resource.ancestors.include? ActiveAdmin::Comment

      #unload if changed
      @mtimes.keys.each do |path|
        if /([\w_]+)\.rb$/.match(path)
          resource_name =  $1.classify
          if resource_name == resource.to_s
            begin
              mtime = File.mtime(path)
              return mtime != @mtimes[path]
            rescue
              @mtimes.delete(path)
              return true
            end
          end
        end
      end
      true
    end
  end
end
