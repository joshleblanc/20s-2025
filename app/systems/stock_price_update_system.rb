class StockPriceUpdateSystem 
    def call(args)
        args.state.entities.each_entity(:stock, :price_history) do |entity_id, stock, price_history|
            new_price = calculate_price(stock.volatility_type, args.state.tick_count, stock.seed, stock.base_price)
            price_history.history.push(new_price)
            if price_history.history.length > price_history.max_history
                price_history.history.shift
            end
            stock.current_price = new_price
        end
    end

    def calculate_price(type, time, seed, base)
        case type
        when "steady"
            base + (time * 2) + noise(seed, time)
        when "rollercoaster"
            base + Math.sin(time * 3 + seed) * 20
        when "pump_dump"
            return base + time * 5 if time < 10
            base + (20 - time) * 5
        when "late_bloomer"
            return base + noise(seed, time) if time < 15 
            base + (time - 15) * 10
        when "fake_out"
            return base + time * 3 if time < 8 
            base - (time - 8) * 2
        end
    end

    def noise(seed, time)
        x = time + seed * 1000
        return (
            Math.sin(x * 0.4) * 0.5 +
            Math.sin(x * 1.1) * 0.25 +
            Math.sin(x * 2.7) * 0.15 +
            Math.sin(x * 5.3) * 0.1
        )
    end
end