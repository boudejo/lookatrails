module TW
    
    module Partials
    
      module Default
        
        PAGING_TABLE = %{
          <% if data || info then %>
            <div <%= html %>>
               <table cellpadding="0" cellspacing="0" width="100%">
                 <tr>
                   <% if data then %><td><%= data %></td><% end %>
                   <% if info then %><td><%= info %></td><% end %>
                 </tr>
               </table>
           	</div>
         	<% end %>
        }
        
      end
    
      module Form
        
        LABEL = %{<%= prepend_label %><%= label %><%= append_label %>}
        FIELD = %{<%= prepend_field %><%= field %><%= append_field %>}

        PLAIN_LABEL = %{#{LABEL}}
        PLAIN_FIELD = %{#{FIELD}}
               
        LABEL_FIELD = %{#{PLAIN_LABEL} #{PLAIN_FIELD}}
        FIELD_LABEL = %{#{PLAIN_FIELD} #{PLAIN_LABEL}}
        
        DEFAULT = %{
          <p<%= container %><%= style %>>#{LABEL_FIELD}</p>
        }
        DEFAULT_REVERSE = %{
           <p<%= container %><%= style %>>#{FIELD_LABEL}</p>
        }
        
        LIST_ITEM = %{
          <li<%= container %><%= style %>>#{LABEL_FIELD}</li>
        }
        
        LIST_ITEM_REVERSE = %{
          <li<%= container %><%= style %>>#{FIELD_LABEL}</li>
        }

        TABLE_COLUMN = %{
  			  <td class="label">#{LABEL}</td> 
  				<td class="element">#{FIELD}</td>
        }
        
        TABLE_COLUMN_REVERSE = %{
          <td class="element">#{FIELD}</td>
  				<td class="label">#{LABEL}</td> 
        }
               
        TABLE_ROW = %{
            <tr<%= container %><%= style %>>
  						#{TABLE_COLUMN}
  					</tr>
        }
        
        TABLE_ROW_REVERSE = %{
            <tr<%= container %><%= style %>>
              #{TABLE_COLUMN_REVERSE} 
  					</tr>
        }
        
        READONLY_FIELD = %{
          <span class="readonly"<%= container %><%= style %>><%= value %></span>
        }        
        
        READONLY_TEXTAREA = %{
          <p class="readonly"<%= container %><%= style %>><%= value %></p>
        }
        
      end

    end
    
end