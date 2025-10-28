class GraphSystem
    def call(args)
        args.state.entities.each_entity(:graph, :rect, :stock, :price_history) do |entity_id, graph, rect, stock, price_history|
            num_bars = price_history.history.length
            next if num_bars.zero?

            width = rect.w.fdiv(num_bars)
            
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
                window_size = [price_history.history.length, 60].min
                recent_prices = price_history.history.last(window_size)
                trend_start = recent_prices.first
                trend_end = recent_prices.last
                percent_change = if trend_start && trend_start.nonzero?
                    ((trend_end - trend_start) / trend_start.to_f) * 100
                else
                    0
                end

                trend_label, trend_color = if percent_change > 5
                    ["Trend: Rising (+#{percent_change.round(1)}%) ↑", { r: 50, g: 205, b: 50 }]
                elsif percent_change < -5
                    ["Trend: Falling (#{percent_change.round(1)}%) ↓", { r: 255, g: 99, b: 71 }]
                else
                    ["Trend: Sideways (#{percent_change.round(1)}%) →", { r: 255, g: 215, b: 0 }]
                end

                mean_price = recent_prices.sum / recent_prices.length.to_f
                variance = recent_prices.sum { |p| (p - mean_price) ** 2 } / recent_prices.length.to_f
                std_dev = Math.sqrt(variance)
                volatility_pct = mean_price.zero? ? 0 : (std_dev / mean_price) * 100

                volatility_label, volatility_color = if volatility_pct < 2
                    ["Volatility: Low", { r: 173, g: 216, b: 230 }]
                elsif volatility_pct < 5
                    ["Volatility: Medium", { r: 255, g: 215, b: 0 }]
                else
                    ["Volatility: High", { r: 255, g: 140, b: 0 }]
                end

                # Stock symbol inside chart
                args.outputs.labels << {
                    x: rect.x + rect.w / 2,
                    y: rect.y + rect.h - 15,
                    text: "#{stock.symbol} (#{stock.volatility_type})",
                    size_px: 14,
                    anchor_x: 0.5,
                    anchor_y: 0.5
                }

                # Trend label
                args.outputs.labels << {
                    x: rect.x + rect.w / 2,
                    y: rect.y + rect.h - 35,
                    text: trend_label,
                    size_px: 12,
                    anchor_x: 0.5,
                    anchor_y: 0.5,
                    r: trend_color[:r],
                    g: trend_color[:g],
                    b: trend_color[:b]
                }

                # Volatility label
                args.outputs.labels << {
                    x: rect.x + rect.w / 2,
                    y: rect.y + rect.h - 52,
                    text: volatility_label,
                    size_px: 11,
                    anchor_x: 0.5,
                    anchor_y: 0.5,
                    r: volatility_color[:r],
                    g: volatility_color[:g],
                    b: volatility_color[:b]
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
                    x: rect.x + rect.w - 40,
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