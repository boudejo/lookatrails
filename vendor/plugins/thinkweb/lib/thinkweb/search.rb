module TW
  
   # Custom search functionality
  module Search
    # TODO: http://www.techotopia.com/index.php/MySQL_Regular_Expression_Searches
    def self.format_like(search)
      if search then
        searchar = search[0,1]
        search = (search[0,1] == '@') ? search[1,search.length] : search
        # Cleanup searchstring
          searchfor = ''
         
          search = search.gsub('\\', '')
          search = search.gsub('_', '')
          search = search.gsub('%', '')
          search = search.gsub('*', '%')
          search = search.gsub('?', '_')
          searchfor = search
          
          if searchfor.length == 0 then
            return '%'          
          else
            if searchar == '@' then
              # Do a literal search for the given string
              return '%'+searchfor+'%'
            else 
              if search.length < 3 then
                # Only look fo a match at the beginning of the string
                return searchfor+'%';
              else
                if search.length < 5 then
                    # Look for a match in the entire string
                    return '%'+searchfor+'%'
                else 
                  # Put a % between every character
                  # Remove whitespaces
                  searchfor = searchfor.gsub(' ', '')
                  # Loop through string and add % after every character
                  searchformatted = '%'
                  searchfor.each_char do |c|
                    if c != '%' && c!= '_' then
                      searchformatted += c+'%'
                    else 
                      if c == '_' then
                        if searchformatted[searchformatted.length-1, searchformatted.length] == '%' then
                          searchformatted = searchformatted[0,searchformatted.length-1]
                        end
                        searchformatted += c;
                      else
                        searchformatted += '%'
                      end
                    end
                  end
                  return searchformatted
                end
              end
            end
          end
       end
    end
  end
  
end