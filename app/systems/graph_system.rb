class GraphSystem
    def call(args)
        args.state.entities.each_entity(:graph, :rect, :stock, :price_history) do |entity_id, graph, rect, stock, price_history|
            num_bars = price_history.history.length
            width = rect.w / num_bars
            
            max_price = price_history.history.max
            min_price = price_history.history.min
            price_range = max_price - min_price rescue -1
            
            # Draw bars
            price_history.history.each_with_index do |price, index|
                if price_range > 0
                    percentage = (price - min_price) / price_range
                else
                    percentage = 0.5
                end
                
                h = percentage * rect.h
                
                if index == 0
                    color = { r: 128, g: 128, b: 128 } 
                elsif price >= price_history.history[index - 1]
                    color = { r: 105, g: 210, b: 105 }
                else
                    color = { r: 255, g: 0, b: 0 } 
                end
                
                args.outputs.solids << { 
                    x: (rect.x + index * width), 
                    y: rect.y, 
                    w: width, 
                    h: h, 
                    r: color[:r], g: color[:g], b: color[:b]
                }
            end
            
            # Draw labels if we have price history
            if price_history.history.length > 0
                # Stock symbol inside chart
                args.outputs.labels << {
                    x: rect.x + rect.w / 2,
                    y: rect.y + rect.h - 15,
                    text: "#{stock.symbol} (#{stock.volatility_type})",
                    size_px: 14,
                    anchor_x: 0.5,
                    anchor_y: 0.5
                }
                
                # Max price label
                args.outputs.labels << {
                    x: rect.x - 5,
                    y: rect.y + rect.h,
                    text: max_price&.round(2).to_s,
                    size_px: 10,
                    anchor_x: 1,
                    anchor_y: 0.5
                }
                
                # Min price label
                args.outputs.labels << {
                    x: rect.x - 5,
                    y: rect.y,
                    text: min_price&.round(2).to_s,
                    size_px: 10,
                    anchor_x: 1,
                    anchor_y: 0.5
                }
                
                # Current price label
                args.outputs.labels << {
                    x: rect.x + rect.w + 5,
                    y: rect.y + rect.h / 2,
                    text: stock.current_price&.round(2).to_s,
                    size_px: 12,
                    anchor_x: 0,
                    anchor_y: 0.5
                }
            end
        end
    end
end