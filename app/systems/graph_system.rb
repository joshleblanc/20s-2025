class GraphSystem
    def call(args)
        args.state.entities.each_entity(:graph, :rect, :stock, :price_history) do |entity_id, graph, rect, stock, price_history|
            num_bars = price_history.history.length
            width = rect.w / num_bars
            
            max_price = price_history.history.max
            min_price = price_history.history.min
            price_range = max_price - min_price rescue -1
            
            price_history.history.each_with_index do |price, index|
                if price_range > 0
                    percentage = (price - min_price) / price_range
                else
                    percentage = 0.5
                end
                
                h = percentage * rect.h
                args.outputs.solids << { x: (rect.x + index * width) + 1, y: rect.y, w: width - 2, h: h }
            end
        end
    end
end