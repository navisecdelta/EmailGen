class CredE
    def initialize(domain, company, email_format)
        @email_format = email_format
        @domain = domain
        @company = company
        @agent = Mechanize.new
        @agent.user_agent = 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36'
    end

    def format_email(first, last)
        domain = @domain
        f = first[0]
        l = last[0]

        # Since we're doing a sketchy eval statement, the gsub simply converts {} to #{} so that eval can understand it. 
        # This is the secret sauce to {first}{last}@{domain}
        email = eval("email = \"#{@email_format.gsub('{', '#{')}\"")

        email
    end

    def pull(start = 1)
        data = {}
        html = @agent.get("https://www.bing.com/search?q=site%3Alinkedin.com%2Fin%20%22#{@company}%22&first=#{start}&afj=100&FORM=PERE").body
        page = Nokogiri::HTML(html)
        data['count'] = page.css('.sb_count').text
        data['names'] = []
        page.css('li.b_algo').each do |result|
        data['names'].push(result.css('h2').css('a').text)
        end
        data
    end

    def parse_linkedstrings(string)
        firstchunk = string.split(' - ')[0]
        backup = firstchunk
        firstchunk.split(' ').each do |chunk|
            if chunk == chunk.upcase
                backup.gsub!(chunk, '')
            elsif chunk.include? '['
                backup.gsub!(chunk, '')
            end
        end
        names = backup.tr(',.[]()@', '').split(' ')
        names
    end

    def scan()
        results = []
        initial_pull = pull(1)
        results.push(*initial_pull['names'])
        total = initial_pull['count'].delete(',').split(' ')[0].to_i
        current_page = initial_pull['names'].length - 1


        # use whatever is smaller
        top = 500 >= total ? total : 500
        progressbar = ProgressBar.create(:format => '%a %e %B %p%% %t')

        until current_page >= top
            perc = (current_page.to_f / top.to_f) * 100
            progressbar.progress = perc

            this_pull = pull(current_page)
            results.push(*this_pull['names'])
            current_page = results.length - 1
        end

        emails = []

        results.each do |result|
            data = {}
            group = parse_linkedstrings(result)
            begin
                data['first'] = group[0].capitalize
                data['last'] = group[-1].capitalize
            rescue StandardError
                # puts "opps"
            end
            begin
                emails.push(format_email(data["first"].downcase, data["last"].downcase))
            rescue StandardError
                # puts "uber oops"
            end
        end

        return emails.uniq!
    end
end