module GoogleSafeBrowsing
  class ChunkHelper
    def self.build_chunk_list(list=nil)
      lists = if list
                list.to_a
              else
                GoogleSafeBrowsing.config.current_lists
              end

      ret = ''
      lists.each do |list|
        ret += "#{list};"
        action_strings = []


        nums = GoogleSafeBrowsing::AddShavar.select('distinct chunk_number').where(:list => list).
          order(:chunk_number).collect{|c| c.chunk_number }
        action_strings << "a:#{squish_number_list(nums)}" if nums.any?

        nums = GoogleSafeBrowsing::SubShavar.select('distinct chunk_number').where(:list => list).
          order(:chunk_number).uniq.collect{|c| c.chunk_number }
        action_strings << "s:#{squish_number_list(nums)}" if nums.any?

        ret += "#{action_strings.join(':')}\n"
      end

      #puts ret
      ret
    end

    def self.squish_number_list(chunks)
      num_strings = []

      streak_begin = chunks[0]
      last_num = chunks.shift
      chunks.each do |c|
        if c == last_num+1
          #puts "streak continues"
        else
          #puts "streak has ended"
          if streak_begin != last_num
            streak_string = "#{streak_begin}-#{last_num}"
            #puts "there is a streak: #{streak_string}"
            num_strings << streak_string
          else
            #puts "streak was one long: #{last_num}"
            num_strings << last_num
          end
          streak_begin = c
        end
        last_num = c
      end

      if streak_begin == chunks[-1]
        num_strings << streak_begin
      else
        num_strings << "#{streak_begin}-#{chunks[-1]}"
      end

      num_strings.join(',')
    end

    def self.chunklist_to_sql(chunk_list)
      ret_array = []
      chunk_list.split(',').each do |s|
        if s.index('-')
          range = s.split('-')
          ret_array << "chunk_number between #{range[0]} and #{range[1]}"
        else
          ret_array << "chunk_number = #{s}"
        end
      end
      ret_array.join(" or ")
    end

  end
end
