module Funky
  class Page
    def self.where(id:)
      return nil unless id
      instantiate_collection(fetch_and_parse_data Array(id))
    end

  private

    def self.fetch_and_parse_data(ids)
      if ids.is_a?(Array) && ids.size > 1
        response = Connection::API.batch_request(ids: ids, fields: fields)
      else
        id = ids.is_a?(Array) ? ids.first : ids
        response = Connection::API.request(id: id, fields: fields)
      end
      parse response
    rescue ContentNotFound
      []
    end

    def self.parse(response)
      if response.code == '200'
        body = JSON.parse response.body, symbolize_names: true
        if body.is_a? Array
          body.select{|item| item[:code] == 200}.collect do |item|
            JSON.parse(item[:body], symbolize_names: true)
          end.compact
        else
          [body]
        end
      else
        raise ContentNotFound, "Error #{response.code}: #{response.body}"
      end
    end

    def self.instantiate_collection(items)
      items.collect { |item| new item }
    end

    def self.fields
      [
        'name',
        'username'
      ]
    end
  end
end
