class PrinterService
  require 'open-uri'
  require 'nokogiri'
  def print(url = nil)
    return "No URL provided" if url.blank?

    begin
      html = URI.open(url, &:read)
      doc  = Nokogiri::HTML.parse(html)
    rescue Exception => e
      return "Error fetching or parsing the document: #{e.message}"
    end

    cells = doc.css('td').map { |td| td.text }

    # group cells into [x, char, y] and remove the header row
    rows = cells.each_slice(3).to_a
    rows.shift
    return 'Document contains no grid data.' if rows.empty?

    # initialize grid
    grid  = {}
    max_x = 0
    max_y = 0

    # populate the grid
    rows.each do |x_str, char, y_str|
      x = x_str.to_i
      y = y_str.to_i
      grid[[x, y]] = char

      # track maximum x and y values for printing
      max_x = x if x > max_x
      max_y = y if y > max_y
    end

    # highest-y is top row, print from max_y down to 0
    max_y.downto(0) do |y|
      line = []
      (0..max_x).each do |x|
        char = grid[[x, y]] || ' ' # default to space if no character is found
        line << char
      end
      puts line.join # print line as a string
    end
    nil
  end
end

# To run the service, use:
# PrinterService.new.print('https://docs.google.com/document/d/e/2PACX-1vTER-wL5E8YC9pxDx43gk8eIds59GtUUk4nJo_ZWagbnrH0NFvMXIw6VWFLpf5tWTZIT9P9oLIoFJ6A/pub')