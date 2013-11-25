module GoogleSafeBrowsing
  class ChunkHelper
    def self.build_chunk_list(*lists)
      lists = if lists.any?
                lists.to_a
              else
                GoogleSafeBrowsing.config.current_lists
              end

      ret = ''
      lists.each do |list|
        ret += "#{list};"
        action_strings = []


        nums = GoogleSafeBrowsing::AddShavar.where(list: list)
                                            .order(:chunk_number)
                                            .select('distinct chunk_number')
                                            .map(&:chunk_number)
        action_strings << "a:#{squish_number_list(nums)}" if nums.any?

        nums = GoogleSafeBrowsing::SubShavar.where(list: list)
                                            .order(:chunk_number)
                                            .select('distinct chunk_number')
                                            .map(&:chunk_number)
        action_strings << "s:#{squish_number_list(nums)}" if nums.any?

        ret += "#{action_strings.join(':')}#{":mac" if GoogleSafeBrowsing.config.have_keys?}\n"
      end

      ret
    end

    def self.squish_number_list(chunks)
      num_strings = []
      streak_begin = last_num = chunks.shift

      chunks.each do |c|
        unless c == last_num+1
          if streak_begin != last_num
            num_strings << "#{streak_begin}-#{last_num}"
          else
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
