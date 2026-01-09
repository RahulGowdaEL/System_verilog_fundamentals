class transaction;
  
  randc bit        op;
  rand bit [31:0] awaddr;
  rand bit [31:0] wdata;
  rand bit [31:0] araddr;
       bit [31:0] rdata;
       bit [1:0]  wresp;
       bit [1:0]  rresp;
  
  constraint valid_addr_range {awaddr == 1; araddr == 1;}
  constraint valid_data_range {wdata < 12; rdata < 12;}
 
  
endclass
 
 
 
//////////////////////////////////
class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  
  event done; ///gen completed sending requested no. of transaction
  event sconext; ///scoreboard complete its work
 
   int count = 0;
  
  function new( mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;   
    tr =new();
  endfunction
  
    task run();
    for(int i=0; i < count; i++) 
    begin
      assert(tr.randomize) else $error("Randomization Failed");
      $display("[GEN] : OP : %0b awaddr : %0d wdata : %0d araddr : %0d",tr.op, tr.awaddr, tr.wdata, tr.araddr);
      mbxgd.put(tr);
      @(sconext);
    end
    ->done;
  endtask
  
   
endclass
 
 
/////////////////////////////////////
 
 
class driver;
  
  virtual axi_if vif;
  
  transaction tr;
  
  
  mailbox #(transaction) mbxgd;
  mailbox #(transaction) mbxdm;
 
  
  function new( mailbox #(transaction) mbxgd,  mailbox #(transaction) mbxdm);
    this.mbxgd = mbxgd; 
    this.mbxdm = mbxdm;
  endfunction
  
  //////////////////Resetting System
  task reset();
    
     vif.resetn  <= 1'b0; 
     vif.awvalid <= 1'b0;
     vif.awaddr  <= 0; 
     vif.wvalid <= 0;
     vif.wdata <= 0;
     vif.bready <= 0;  
     vif.arvalid <= 1'b0;
     vif.araddr <= 0;
    repeat(5) @(posedge vif.clk);
     vif.resetn <= 1'b1;
    
    $display("-----------------[DRV] : RESET DONE-----------------------------"); 
  endtask
  
  
   task write_data(input transaction tr);
     $display("[DRV] : OP : %0b awaddr : %0d wdata : %0d ",tr.op, tr.awaddr, tr.wdata);
      mbxdm.put(tr);
      vif.resetn  <= 1'b1;
      vif.awvalid <= 1'b1;
      vif.arvalid <= 1'b0;  ////disable read
      vif.araddr  <= 0;
      vif.awaddr  <= tr.awaddr;
      @(negedge vif.awready);
      vif.awvalid <= 1'b0;
      vif.awaddr  <= 0;
      vif.wvalid  <= 1'b1;
      vif.wdata   <= tr.wdata;
      @(negedge vif.wready);
      vif.wvalid  <= 1'b0;
      vif.wdata   <= 0;
      vif.bready  <= 1'b1;
      vif.rready  <= 1'b0;
      @(negedge vif.bvalid);
      vif.bready  <= 1'b0;
   endtask
     
     
   task read_data(input transaction tr);
     $display("[DRV] : OP : %0b araddr : %0d ",tr.op, tr.araddr);
      mbxdm.put(tr);
      vif.resetn  <= 1'b1;
      vif.awvalid <= 1'b0;
      vif.awaddr  <= 0;
      vif.wvalid  <= 1'b0;
      vif.wdata   <= 0;
      vif.bready  <= 1'b0;
      vif.arvalid <= 1'b1;  
      vif.araddr  <= tr.araddr;
      @(negedge vif.arready);
      vif.araddr  <= 0;
      vif.arvalid <= 1'b0;
      vif.rready  <= 1'b1;
      @(negedge vif.rvalid);
      vif.rready  <= 1'b0;
   endtask
 
  
 
  
  task run();
    
    forever 
    begin        
      mbxgd.get(tr);
      @(posedge vif.clk);     
     /////////////////////////write mode check and sig gen 
      if(tr.op == 1'b1) 
        write_data(tr);    
      else
        read_data(tr);    
    end
 
  endtask
  
    
  
endclass
///////////////////////////////////////////////////////
 
 
class monitor;
    
  virtual axi_if vif; 
  transaction tr,trd;
  mailbox #(transaction) mbxms;
  mailbox #(transaction) mbxdm;
 
 
  function new( mailbox #(transaction) mbxms , mailbox #(transaction) mbxdm);
    this.mbxms = mbxms;
    this.mbxdm = mbxdm;
  endfunction
  
  
  task run();
    
    tr = new();
    
    forever 
      begin 
        
      @(posedge vif.clk);
        mbxdm.get(trd);
        
        if(trd.op == 1)
          begin
            
            tr.op     = trd.op;
            tr.awaddr = trd.awaddr;
            tr.wdata  = trd.wdata;
            @(posedge vif.bvalid);
            tr.wresp  = vif.wresp;
            @(negedge vif.bvalid);
            $display("[MON] : OP : %0b awaddr : %0d wdata : %0d wresp:%0d",tr.op, tr.awaddr, tr.wdata, tr.wresp);
            mbxms.put(tr); 
          end
        else 
          begin
            tr.op = trd.op;
            tr.araddr = trd.araddr;
            @(posedge vif.rvalid);
            tr.rdata = vif.rdata;
            tr.rresp = vif.rresp;
            @(negedge vif.rvalid);
            $display("[MON] : OP : %0b araddr : %0d rdata : %0d rresp:%0d",tr.op, tr.araddr, tr.rdata, tr.rresp);
            mbxms.put(tr); 
          end
    
      end 
  endtask
 
  
  
endclass
 
///////////////////////////////////////
 
 
class scoreboard;
  
  transaction tr,trd;
  event sconext;
 
  
  mailbox #(transaction) mbxms;
 
 
  
  bit [31:0] temp;
  bit [31:0] data[128] = '{default:0};
 
  
 
  
  function new( mailbox #(transaction) mbxms);
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    forever 
      begin  
        
      mbxms.get(tr);
      
        if(tr.op == 1)
              begin
                $display("[SCO] : OP : %0b awaddr : %0d wdata : %0d wresp : %0d",tr.op, tr.awaddr, tr.wdata, tr.wresp);
                if(tr.wresp == 3)
                $display("[SCO] : DEC ERROR");  
                else begin
                data[tr.awaddr] = tr.wdata;
                $display("[SCO] : DATA STORED ADDR :%0d and DATA :%0d", tr.awaddr, tr.wdata);
                end
              end
            else
              begin
                $display("[SCO] : OP : %0b araddr : %0d rdata : %0d rresp : %0d",tr.op, tr.araddr, tr.rdata, tr.rresp);
                temp = data[tr.araddr];
                if(tr.rresp == 3)
                  $display("[SCO] : DEC ERROR");
                else if (tr.rresp == 0 && tr.rdata == temp)
                  $display("[SCO] : DATA MATCHED");
                else
                  $display("[SCO] : DATA MISMATCHED");
              end
        $display("----------------------------------------------------");
        ->sconext;
    end
  endtask
  
  
endclass
 
 
///////////////////////////////////////////////////
 
 module tb;
   
  monitor mon; 
  generator gen;
  driver drv;
  scoreboard sco;
   
   
  event nextgd;
  event nextgm;
  
 
  
   mailbox #(transaction) mbxgd, mbxms, mbxdm;
  
  axi_if vif();
   
  axilite_s dut (vif.clk, vif.resetn, vif.awvalid, vif.awready, vif.awaddr,  vif.wvalid, vif.wready,  vif.wdata,  vif.bvalid, vif.bready,  vif.wresp , vif.arvalid,  vif.arready, vif.araddr, vif.rvalid, vif.rready, vif.rdata, vif.rresp);
 
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;
  
  initial begin
 
    mbxgd = new();
    mbxms = new();
    mbxdm = new();
    gen = new(mbxgd);
    drv = new(mbxgd,mbxdm);
    
    mon = new(mbxms,mbxdm);
    sco = new(mbxms);
    
    gen.count = 10;
    drv.vif = vif;
    mon.vif = vif;
 
    
    gen.sconext = nextgm;
    sco.sconext = nextgm;
    
  end
  
  initial begin
    drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_any  
    wait(gen.done.triggered);
    $finish;
  end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;   
  end
 
   
endmodule

module axilite_s(
 
    input  wire         s_axi_aclk,
    input  wire         s_axi_aresetn,
    input  wire         s_axi_awvalid,
    output reg          s_axi_awready,
    input  wire [31: 0] s_axi_awaddr,
 
    input  wire         s_axi_wvalid,
    output reg         s_axi_wready,
    input  wire [31: 0] s_axi_wdata,
 
    output reg         s_axi_bvalid,
    input  wire         s_axi_bready,
    output reg  [1: 0] s_axi_bresp,
 
    input wire         s_axi_arvalid,
    output reg         s_axi_arready,
    input wire [31: 0] s_axi_araddr,
 
    output reg         s_axi_rvalid,
    input wire         s_axi_rready,
    output reg [31: 0] s_axi_rdata,
    output reg  [1: 0] s_axi_rresp
    );
 
localparam idle            = 0, 
           send_waddr_ack  = 1,
           send_raddr_ack  = 2,
           send_wdata_ack  = 3,
           update_mem      = 4,
           send_wr_err     = 5,
           send_wr_resp    = 6,
           gen_data        = 7,
           send_rd_err     = 8,
           send_rdata      = 9;
           
           
reg [3:0] state      = idle;
reg [3:0] next_state = idle;
reg [1:0] count    = 0;
reg [31:0] waddr, raddr, wdata, rdata;
 
reg [31:0] mem [128];
                  
           
always@(posedge s_axi_aclk)
begin
if (s_axi_aresetn == 1'b0)
begin
            state <= idle;
            for(int i = 0; i < 128; i++)
            begin
            mem[i] <= 0;
            end
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
            s_axi_bresp   <= 0;
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
            s_axi_rdata   <= 0;
            s_axi_rresp   <= 0;
            waddr         <= 0;
            raddr         <= 0;
            wdata         <= 0;
            rdata         <= 0;      
 end
 else 
 begin
        case(state)
        idle: 
        begin
 
            s_axi_awready <= 0;
            s_axi_wready  <= 0;
            s_axi_bvalid  <= 0;
            s_axi_bresp   <= 0;
            s_axi_arready <= 0;
            s_axi_rvalid  <= 0;
            s_axi_rdata   <= 0;
            s_axi_rresp   <= 0;
            waddr         <= 0;
            raddr         <= 0;
            wdata         <= 0;
            rdata         <= 0;
            count         <= 0;
            s_axi_rvalid  <= 1'b0;
            
            if (s_axi_awvalid == 1'b1)
                    begin
                    state         <= send_waddr_ack;
                    waddr         <= s_axi_awaddr;
                    s_axi_awready <= 1'b1;
                    end
            else if (s_axi_arvalid == 1'b1)
                    begin
                    state         <= send_raddr_ack;
                    raddr         <= s_axi_araddr;
                    s_axi_arready <= 1'b1;
                    end
            else
                    begin
                    state         <= idle;
                    end
            
        end
            
       send_waddr_ack : 
       begin
        s_axi_awready <= 1'b0;
        if(s_axi_wvalid)
                  begin
                  wdata        <= s_axi_wdata;
                  s_axi_wready <= 1'b1;
                  state        <= send_wdata_ack;
                  end
        else
                  begin
                  state        <= send_waddr_ack;
                  end
       end
       
       send_wdata_ack: 
       begin
          s_axi_wready <= 1'b0;
          if(waddr < 128)
                   begin
                   state      <= update_mem;
                   mem[waddr] <= wdata;
                   end 
          else
                 begin
                 state        <= send_wr_err;
                 s_axi_bresp <= 2'b11; //error response
                 s_axi_bvalid <= 1'b1; 
                 end
       end
       
       update_mem: 
       begin
       mem[waddr] <= wdata;
       state      <= send_wr_resp;
       end
       
       send_wr_resp: 
       begin
       s_axi_bresp  <= 2'b00;
       s_axi_bvalid <= 1'b1;
       if(s_axi_bready)
                 begin
                 state        <= idle;
                 end
       else 
                 begin
                 state        <= send_wr_resp;
                 end
       end
       
       send_wr_err: begin
       if(s_axi_bready)
                 begin
                 state   <= idle;
                 end
       else 
                 begin
                 state <= send_wr_err;
                 end
       end
       
       
       ////////////////read operation
        send_raddr_ack : 
        begin
        s_axi_arready = 1'b0;
        if(raddr < 128)
                state <= gen_data;
        else
                begin
                s_axi_rvalid <= 1'b1;
                state <= send_rd_err;
                s_axi_rdata  <= 0;
                s_axi_rresp  <= 2'b11;
                end
       end
    
    
        gen_data: begin
        if(count < 2)
                begin
                rdata <= mem[raddr];
                state <= gen_data;
                count <= count + 1;
                end       
        else
                begin
                s_axi_rvalid <= 1'b1;
                s_axi_rdata  <= rdata;
                s_axi_rresp  <= 2'b00;
                if(s_axi_rready)
                   state <= idle;
                else
                   state <=  gen_data;
                end
        end
        
 
        send_rd_err:
        begin
        if(s_axi_rready)
                begin
                state <= idle;
                end
        else
                begin
                state <= send_rd_err;
                end
        end
        
 
       default: state <= idle;
    endcase
end
end
 
 
 
endmodule
 
/////////////////////////////
interface axi_if;
  logic clk,resetn;
  logic awvalid, awready;
  logic arvalid, arready;
  logic wvalid, wready;
  logic bready, bvalid;
  logic rvalid, rready;
  logic [31:0] awaddr, araddr, wdata, rdata;
  logic [1:0] wresp,rresp;
  
endinterface


///wisbone code

`timescale 1ns / 1ps
 
interface wb_if;
    logic clk;
    logic we;
    logic strb;
    logic rst;
    logic [7:0] addr;
    logic [7:0] wdata;
    logic [7:0] rdata;
    logic  ack;
endinterface
 
 
module mem_wb(
    input clk,we,strb,rst, 
    input [7:0] addr,
    input [7:0] wdata,
    output reg [7:0] rdata,
    output reg ack 
    );
 
reg [7:0] mem[256];
 
reg [7:0] temp;
 
 
typedef enum bit [1:0] {idle = 0, check_mode = 1, write = 2, read = 3} state_type; 
state_type state, next_state;
 
//////////////////////reset decoder    
always_ff@(posedge clk)
begin  
if(rst)
begin
state <= idle;
end
else
state <= next_state;
end
 
///////////next state and output decoder
always_comb
begin
case(state)
 
idle: begin
 ack   = 1'b0;
 rdata = 8'h00;
 next_state = check_mode; 
for(int i = 0; i < 256; i++) begin
  mem[i] <= 8'h11;
end
  
end  
 
check_mode: begin
 if(strb && we)
   begin
   next_state = write;
   end
 else if (strb && !we) 
   begin
   next_state = read;
   temp = mem[addr];
   end
 else
   begin
   next_state = check_mode;
   end
end  
 
 
write: begin
mem[addr] = wdata;
ack = 1'b1;
next_state = idle;
end
 
read: begin
rdata = temp;
ack = 1'b1;
next_state = idle; 
end
 
default: next_state = idle;
endcase
end 
endmodule

class transaction;
 
  randc bit [1:0] opmode; /// write = 0, read = 1, random =2
  rand bit we;
  rand bit strb;
  rand bit [7:0] addr;
  rand bit [7:0] wdata;
  bit [7:0] rdata;
  bit ack;
   
   constraint opmode_c {
   opmode >= 0; opmode < 3;
   }
  
   constraint addr_c {
     addr == 5;
   }
   
   constraint wdata_c {
    wdata > 0; wdata <= 8;
   }
  
    function transaction copy();
    copy       = new();
    copy.opmode  = this.opmode;
    copy.we    = this.we;
    copy.strb  = this.strb;
    copy.addr  = this.addr;
    copy.wdata = this.wdata;
    copy.rdata = this.rdata;
    copy.ack   = this.ack;
    endfunction
  
  function void display(input string tag);
  $display("[%0s] : MODE :%0d WE : %0b STRB : %0b ADDR : %0d WDATA : %0d RDATA : %0d", tag,opmode, we,strb,addr,wdata,rdata);
  endfunction
  
  
endclass
 
/////////////////////////////////////////////////////////////////////////
 
 
class generator;
  
  transaction tr;
  mailbox #(transaction) mbxgd;
  event done; ///gen completed sending requested no. of transaction
  event drvnext; /// dr complete its wor;
  event sconext; ///scoreboard complete its work
 
   int count = 0;
  
  function new( mailbox #(transaction) mbxgd);
    this.mbxgd = mbxgd;   
    tr =new();
  endfunction
  
    task run();
    
      for(int i=0; i< count; i++) begin
      assert(tr.randomize) else $error("Randomization Failed"); 
      $display("------------------------------------------");
      tr.display("GEN");
      mbxgd.put(tr.copy); 
      @(drvnext);
      @(sconext);
      end
      
    ->done;
      
  endtask
  
   
endclass
///////////////////////////////////////////////////////////
 
class driver;
 
virtual wb_if vif;
transaction tr;
event drvnext;
 
  mailbox #(transaction) mbxgd;
 
  
  function new( mailbox #(transaction) mbxgd );
    this.mbxgd = mbxgd; 
  endfunction
  
   task reset();
   vif.rst   <= 1'b1;
   vif.we    <= 0;
   vif.addr  <= 0;
   vif.wdata <= 0;
   vif.strb  <= 0;
   repeat(10) @(posedge vif.clk);
   vif.rst <= 1'b0;
   repeat(5) @(posedge vif.clk);
   $display("[DRV] : RESET DONE");
  endtask
 
  task write();
  @(posedge vif.clk);
  $display("[DRV] : DATA WRITE MODE");
  vif.rst   <= 1'b0;
  vif.we    <= 1'b1;
  vif.strb  <= 1'b1;
  vif.addr  <= tr.addr;
  vif.wdata <= tr.wdata;
  @(posedge vif.ack);
  @(posedge vif.clk);
  ->drvnext;
  endtask
  
  task read();
  @(posedge vif.clk);
  $display("[DRV] : DATA READ MODE");
  vif.rst   <= 1'b0;
  vif.we    <= 1'b0;
  vif.strb  <= 1'b1;
  vif.addr  <= tr.addr;
  @(posedge vif.ack);
  @(posedge vif.clk);
  ->drvnext;
  endtask
  
  task random();
  @(posedge vif.clk);
  $display("[DRV] : RANDOM MODE");
  vif.rst   <= 1'b0;
  vif.we    <= tr.we;
  vif.strb  <= tr.strb;
  vif.addr  <= tr.addr;
  if(tr.we == 1'b1)
  begin
  vif.wdata <= tr.wdata;
  end
  repeat(2)@(posedge vif.clk);
  ->drvnext;
  endtask
  
  
  task run();
   forever begin
     mbxgd.get(tr);
     if(tr.opmode == 0) 
     begin
       write();
     end  
     else if (tr.opmode == 1) 
     begin
       read();
     end  
     else if(tr.opmode == 2) 
     begin
       random();
     end  
   end
  endtask
  
 
endclass
 
////////////////////////////////////////////////
 
class monitor;
    
  virtual wb_if vif;
  transaction tr;
  
  mailbox #(transaction) mbxms;
 
  
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  
  task run();
    
    tr = new();
    
    forever 
      begin 
        wait( vif.rst == 1'b0); 
       repeat(5) @(posedge vif.clk);
        @(posedge vif.clk);
        if(vif.strb == 1'b0)
        begin
        tr.strb = vif.strb;
        repeat(2) @(vif.clk);
        $display("[MON] : STRB IS ZERO");
        mbxms.put(tr);  
        end
        else
        begin
        @(posedge vif.ack);
        tr.we = vif.we;
        tr.strb = vif.strb;
        tr.wdata = vif.wdata;
        tr.addr = vif.addr;
        tr.rdata = vif.rdata; 
        @(posedge vif.clk);
        $display("[MON] : STRB IS VALID");
        mbxms.put(tr);  
        end
      end 
  endtask
 
endclass
///////////////////////////////////////////////////////////////
 
class scoreboard;
  transaction tr;
  event sconext;
  
  mailbox #(transaction) mbxms;
  
  bit [7:0] data[256] = '{default:0};
  
    
  function new( mailbox #(transaction) mbxms );
    this.mbxms = mbxms;
  endfunction
  
  task run();
   forever begin
    mbxms.get(tr);
    if(tr.strb == 1'b0) 
            begin
            $display("[SCO] : INVALID STROBE");
            end
    else 
      begin
          
          if(tr.we == 1'b1)
                      begin
                       data[tr.addr] = tr.wdata;
                        $display("[SCO] : DATA WRITE DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                      end  
          else 
             begin
                    if(tr.rdata == 8'h11)
                     begin
                     $display("[SCO] : DATA MATCHED : DEFAULT VALUE READ");
                     end
                     else if (tr.rdata == data[tr.addr])
                     begin
                       $display("[SCO] : DATA MATCHED DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                     end
                     else
                     begin
                       $display("[SCO] : DATA MISMATCHED DATA : %0d ADDR : %0d", tr.wdata, tr.addr);
                     end 
             end
        end
      $display("------------------------------------------");
     ->sconext; 
   end
  endtask
endclass
 
 
 
 
///////////////////////////////////////////////////
 
module tb;
   
  generator gen;
  driver drv;
  monitor mon;
  scoreboard sco;
 
  event drvnext, sconext;
  event done;
  
  mailbox #(transaction) mbxgd;
  mailbox #(transaction) mbxms;
  
  wb_if vif();
  mem_wb dut (vif.clk, vif.we, vif.strb, vif.rst, vif.addr, vif.wdata, vif.rdata, vif.ack);
 
  initial begin
    vif.clk <= 0;
  end
  
  always #5 vif.clk <= ~vif.clk;
  
  initial begin
 
    mbxgd = new();
    mbxms = new();
    gen = new(mbxgd);
    drv = new(mbxgd);
    mon = new(mbxms);
    sco = new(mbxms);
    gen.count = 10;
    drv.vif = vif;
    mon.vif = vif;
    
    drv.drvnext = drvnext;
    gen.drvnext = drvnext;
    
    gen.sconext = sconext;
    sco.sconext = sconext;
    
  end
  
  initial begin
      drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
      sco.run();
    join_none  
    wait(gen.done.triggered);
    $finish();
  end
   
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;   
  end
 
 
endmodule
