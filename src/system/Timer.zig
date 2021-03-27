const std = @import("std");


pub const Timer = struct{
    rate: u8,
    ticker: *u16,
    timerFrame : @Frame(time) = undefined,
    lastUpdate : i64, 
    updateRateMS : f32,

    pub fn init(ticker: *u16,rate:u8) Timer {
        var timer = Timer{
            .rate = rate,
            .ticker = ticker,
            .lastUpdate = std.time.milliTimestamp(),
            .updateRateMS = ((1.0 / @intToFloat(f32,rate)) * 1000.0)

        };
        
        //timer.timerFrame = async timer.time();
        return timer;
    }

    pub fn time(self: *Timer) void{
        while(true){
            suspend;
            self.ticker.* -= 1;
            self.lastUpdate = std.time.milliTimestamp();
        }


    }

    pub fn update(self: *Timer) void {
        var timeDiff = @intToFloat(f32, (std.time.milliTimestamp() - self.lastUpdate));
        
        if( timeDiff > self.updateRateMS ){
            if(self.ticker.* > 0){
                self.ticker.* -= 1;
                
            }
            self.lastUpdate = std.time.milliTimestamp();
        }


    }


};