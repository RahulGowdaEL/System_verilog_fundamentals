import uvm_pkg::*;
`include "uvm_macros.svh"
 
//////////////////transaction class
 
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
 
       bit [7:0] din;
       bit       wr;
       bit       addr;
       bit       rst;
       bit [7:0] dout;   
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
  
 
 
endclass
 
///////////////////////////////////////////////////////
////////////////////////driver 
 
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
 
  transaction tr;
  virtual top_if tif;
 
  function new(input string path = "driver", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!uvm_config_db#(virtual top_if)::get(this,"","tif",tif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  ///////////////reset DUT at the start
  task reset_dut();
    @(posedge tif.clk);
    tif.rst  <= 1'b1;
    tif.wr   <= 1'b0;
    tif.din  <= 8'h00;
    tif.addr <= 1'b0;
    repeat(5)@(posedge tif.clk);
    `uvm_info("DRV", "System Reset", UVM_NONE);
    tif.rst  <= 1'b0;
  endtask
  
  //////////////drive DUT
  
  task drive_dut();
    @(posedge tif.clk);
    tif.rst  <= 1'b0;
    tif.wr   <= tr.wr;
    tif.addr <= tr.addr;
    if(tr.wr == 1'b1)
       begin
           tif.din <= tr.din;
         repeat(2) @(posedge tif.clk);
          `uvm_info("DRV", $sformatf("Data Write -> Wdata : %0d",tif.din), UVM_NONE);
       end
      else
       begin  
          repeat(2) @(posedge tif.clk);
           tr.dout = tif.dout;
          `uvm_info("DRV", $sformatf("Data Read -> Rdata : %0d",tif.dout), UVM_NONE);
       end    
  endtask
  
  
  
  ///////////////main task of driver
  
   virtual task run_phase(uvm_phase phase);
      tr = transaction::type_id::create("tr");
     forever begin
        seq_item_port.get_next_item(tr);
        drive_dut();
        seq_item_port.item_done();  
      end
   endtask
 
endclass
 
////////////////////////////////////////////////////////////////////////////////
///////////////////////agent class
 
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
  
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 driver d;
 uvm_sequencer#(transaction) seqr;
 
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   d = driver::type_id::create("d",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); 
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
   d.seq_item_port.connect(seqr.seq_item_export);
endfunction
 
endclass
 
////////////////////////////////////////////////////////////////////////////////////////
 
 
 
//////////////////////building reg model
 
////////////////////////
 
 
class temp_reg extends uvm_reg;
  `uvm_object_utils(temp_reg)
   
 
  rand uvm_reg_field temp;
 
  
  function new (string name = "temp_reg");
    super.new(name,8,UVM_NO_COVERAGE); 
  endfunction
 
 
  
  function void build; 
    
 
    temp = uvm_reg_field::type_id::create("temp");   
    // Configure
    temp.configure(  .parent(this), 
                     .size(8), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                     .reset(0), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(1)); 
 
    
  endfunction
  
endclass
 
 
//////////////////////////////////////creating reg block
 
 
class top_reg_block extends uvm_reg_block;
  `uvm_object_utils(top_reg_block)
  
 
  rand temp_reg 	temp_reg_inst; 
  
 
  function new (string name = "top_reg_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction
 
 
  function void build;
    
 
    temp_reg_inst = temp_reg::type_id::create("temp_reg_inst");
    temp_reg_inst.build();
    temp_reg_inst.configure(this);
 
 
    default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN); // name, base, nBytes
    default_map.add_reg(temp_reg_inst	, 'h0, "RW");  // reg, offset, access
    
    
    default_map.set_auto_predict(1);
    
    lock_model();
  endfunction
endclass
 
 
/////////////////////////////////////////////////////////////////////////////////////
 
class top_reg_seq extends uvm_sequence;
 
  `uvm_object_utils(top_reg_seq)
  
   top_reg_block regmodel;
  
   
  function new (string name = "top_reg_seq"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [7:0] rdata,rdata_m;
    
    
    
     regmodel.temp_reg_inst.write(status,5'h10);
     rdata =   regmodel.temp_reg_inst.get();
     rdata_m = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("Mir : %0d Des : %0d ", rdata_m, rdata), UVM_NONE);
   
     
     regmodel.temp_reg_inst.predict(5'h05);
     rdata =   regmodel.temp_reg_inst.get();
     rdata_m = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("Mir : %0d Des : %0d ", rdata_m, rdata), UVM_NONE);
   
    regmodel.temp_reg_inst.mirror(status,UVM_NO_CHECK);
     rdata =   regmodel.temp_reg_inst.get();
     rdata_m = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("Mir : %0d Des : %0d ", rdata_m, rdata), UVM_NONE);
  
    
  
  endtask
  
  
endclass
 
////////////////////////////////////////////////////////////////////////
///////////////////////reg adapter
 
class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils (top_adapter)
 
  //---------------------------------------
  // Constructor 
  //--------------------------------------- 
  function new (string name = "top_adapter");
      super.new (name);
   endfunction
  
  //---------------------------------------
  // reg2bus method 
  //--------------------------------------- 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;    
    tr = transaction::type_id::create("tr");
    
    tr.wr    = (rw.kind == UVM_WRITE);
    tr.addr  = rw.addr;
    
    if(tr.wr == 1'b1) tr.din = rw.data;
    
    return tr;
  endfunction
 
  //---------------------------------------
  // bus2reg method 
  //--------------------------------------- 
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    transaction tr;
    
    assert($cast(tr, bus_item));
 
    rw.kind = tr.wr ? UVM_WRITE : UVM_READ;
    rw.data = tr.dout;
    rw.addr = tr.addr;
    rw.status = UVM_IS_OK;
  endfunction
endclass
 
 
 
 
////////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
  
  agent          agent_inst;
  top_reg_block  regmodel;   
  top_adapter    adapter_inst;
  
  `uvm_component_utils(env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  //---------------------------------------
  // build_phase - create the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_inst = agent::type_id::create("agent_inst", this);
    regmodel   = top_reg_block::type_id::create("regmodel", this);
    regmodel.build();
    
    
    adapter_inst = top_adapter::type_id::create("adapter_inst",, get_full_name());
  endfunction 
  
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    regmodel.default_map.set_sequencer( .sequencer(agent_inst.seqr), .adapter(adapter_inst) );
    regmodel.default_map.set_base_addr(0);        
  endfunction 
 
endclass
 
//////////////////////////////////////////////////////////////////////////////////////////////////
 
 
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
top_reg_seq trseq;
 
 
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
   trseq  = top_reg_seq::type_id::create("trseq");
  
  // e.set_config_int( "*", "include_coverage", 0 );
endfunction
 
virtual task run_phase(uvm_phase phase);
  
  phase.raise_objection(this);
  
  trseq.regmodel = e.regmodel;
  trseq.start(e.agent_inst.seqr);
  phase.drop_objection(this);
  
  phase.phase_done.set_drain_time(this, 200);
endtask
endclass
 
//////////////////////////////////////////////////////////////
 
 
module tb;
  
    
  top_if tif();
    
  top dut (tif.clk, tif.rst, tif.wr, tif.addr, tif.din, tif.dout);
 
  
  initial begin
   tif.clk <= 0;
  end
 
  always #10 tif.clk = ~tif.clk;
 
  
  
  initial begin
    uvm_config_db#(virtual top_if)::set(null, "*", "tif", tif);
    
    uvm_config_db#(int)::set(null,"*","include_coverage", 0); //to remove include coverage message
 
    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
 
  
endmodule

import uvm_pkg::*;
`include "uvm_macros.svh"
 
//////////////////transaction class
 
class transaction extends uvm_sequence_item;
  `uvm_object_utils(transaction)
 
       bit [7:0] din;
       bit       wr;
       bit       addr;
       bit       rst;
       bit [7:0] dout;   
  
  function new(string name = "transaction");
    super.new(name);
  endfunction
  
 
 
endclass
 
///////////////////////////////////////////////////////
////////////////////////driver 
 
class driver extends uvm_driver#(transaction);
  `uvm_component_utils(driver)
 
  transaction tr;
  virtual top_if tif;
 
  function new(input string path = "driver", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!uvm_config_db#(virtual top_if)::get(this,"","tif",tif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
  ///////////////reset DUT at the start
  task reset_dut();
    @(posedge tif.clk);
    tif.rst  <= 1'b1;
    tif.wr   <= 1'b0;
    tif.din  <= 8'h00;
    tif.addr <= 1'b0;
    repeat(5)@(posedge tif.clk);
    `uvm_info("DRV", "System Reset", UVM_NONE);
    tif.rst  <= 1'b0;
  endtask
  
  //////////////drive DUT
  
  task drive_dut();
    @(posedge tif.clk);
    tif.rst  <= 1'b0;
    tif.wr   <= tr.wr;
    tif.addr <= tr.addr;
    if(tr.wr == 1'b1)
       begin
           tif.din <= tr.din;
         repeat(2) @(posedge tif.clk);
          `uvm_info("DRV", $sformatf("Data Write -> Wdata : %0d",tif.din), UVM_NONE);
       end
      else
       begin  
          repeat(2) @(posedge tif.clk);
           tr.dout = tif.dout;
          `uvm_info("DRV", $sformatf("Data Read -> Rdata : %0d",tif.dout), UVM_NONE);
       end    
  endtask
  
  
  
  ///////////////main task of driver
  
   virtual task run_phase(uvm_phase phase);
      tr = transaction::type_id::create("tr");
     forever begin
        seq_item_port.get_next_item(tr);
        drive_dut();
        seq_item_port.item_done();  
      end
   endtask
 
endclass
 
////////////////////////////////////////////////////////////////////////////////
///////////////////////agent class
 
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
  
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 driver d;
 uvm_sequencer#(transaction) seqr;
 
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   d = driver::type_id::create("d",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); 
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
   d.seq_item_port.connect(seqr.seq_item_export);
endfunction
 
endclass
 
////////////////////////////////////////////////////////////////////////////////////////
 
 
 
//////////////////////building reg model
 
////////////////////////
 
 
class temp_reg extends uvm_reg;
  `uvm_object_utils(temp_reg)
   
 
  rand uvm_reg_field temp;
 
  
  function new (string name = "temp_reg");
    super.new(name,8,UVM_NO_COVERAGE); 
  endfunction
 
 
  
  function void build; 
    
 
    temp = uvm_reg_field::type_id::create("temp");   
    // Configure
    temp.configure(  .parent(this), 
                     .size(8), 
                     .lsb_pos(0), 
                     .access("RW"),  
                     .volatile(0), 
                    .reset(8'h11), 
                     .has_reset(1), 
                     .is_rand(1), 
                     .individually_accessible(1)); 
 
    
  endfunction
  
endclass
 
 
//////////////////////////////////////creating reg block
 
 
class top_reg_block extends uvm_reg_block;
  `uvm_object_utils(top_reg_block)
  
 
  rand temp_reg 	temp_reg_inst; 
  
 
  function new (string name = "top_reg_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction
 
 
  function void build;
    
 
    temp_reg_inst = temp_reg::type_id::create("temp_reg_inst");
    temp_reg_inst.build();
    temp_reg_inst.configure(this);
 
 
    default_map = create_map("default_map", 'h0, 1, UVM_LITTLE_ENDIAN); // name, base, nBytes
    default_map.add_reg(temp_reg_inst	, 'h0, "RW");  // reg, offset, access
    
    
    default_map.set_auto_predict(1);
    
    lock_model();
  endfunction
endclass
 
 
/////////////////////////////////////////////////////////////////////////////////////
 
class rst_seq extends uvm_sequence;
 
  `uvm_object_utils(rst_seq)
  
   top_reg_block regmodel;
    virtual top_if tif;
   
  function new (string name  = "rst_seq"); 
    super.new(name);    
  endfunction
  
  
  
  
 
  task body;  
    uvm_status_e   status;
    bit [7:0] rdata,rdata_m;
    bit [7:0] rst_reg;
    
    //////getting access of interface
    if(!uvm_config_db#(virtual top_if)::get(null,"uvm_test_top","tif",tif))
        `uvm_error("SEQ","Unable to access Interface");
 
    
     tif.rst  <= 1'b1;
     tif.addr <= 1'b0;
     tif.wr   <= 1'b0;
     tif.din  <= 8'h00;
     regmodel.temp_reg_inst.reset();
     repeat(6) @(posedge tif.clk);
     tif.rst <= 1'b0;
     rdata =   regmodel.temp_reg_inst.get();
     rdata_m = regmodel.temp_reg_inst.get_mirrored_value();
    `uvm_info("SEQ", $sformatf("After Reset -> Mir : %0d Des : %0d ", rdata_m, rdata), UVM_NONE);         
  
  endtask
  
  
endclass
 
////////////////////////////////////////////////////////////////////////
///////////////////////reg adapter
 
class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils (top_adapter)
 
  //---------------------------------------
  // Constructor 
  //--------------------------------------- 
  function new (string name = "top_adapter");
      super.new (name);
   endfunction
  
  //---------------------------------------
  // reg2bus method 
  //--------------------------------------- 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;    
    tr = transaction::type_id::create("tr");
    
    tr.wr    = (rw.kind == UVM_WRITE);
    tr.addr  = rw.addr;
    
    if(tr.wr == 1'b1) tr.din = rw.data;
    
    return tr;
  endfunction
 
  //---------------------------------------
  // bus2reg method 
  //--------------------------------------- 
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    transaction tr;
    
    assert($cast(tr, bus_item));
 
    rw.kind = tr.wr ? UVM_WRITE : UVM_READ;
    rw.data = tr.dout;
    rw.addr = tr.addr;
    rw.status = UVM_IS_OK;
  endfunction
endclass
 
 
 
 
////////////////////////////////////////////////////////////////////////
 
class env extends uvm_env;
  
  agent          agent_inst;
  top_reg_block  regmodel;   
  top_adapter    adapter_inst;
  
  `uvm_component_utils(env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  //---------------------------------------
  // build_phase - create the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_inst = agent::type_id::create("agent_inst", this);
    regmodel   = top_reg_block::type_id::create("regmodel", this);
    regmodel.build();
    
    
    adapter_inst = top_adapter::type_id::create("adapter_inst",, get_full_name());
  endfunction 
  
 
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    regmodel.default_map.set_sequencer( .sequencer(agent_inst.seqr), .adapter(adapter_inst) );
    regmodel.default_map.set_base_addr(0);        
  endfunction 
 
endclass
 
//////////////////////////////////////////////////////////////////////////////////////////////////
 
 
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
rst_seq trseq;
 
 
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
   trseq  = rst_seq::type_id::create("trseq");
  
  // e.set_config_int( "*", "include_coverage", 0 );
endfunction
 
virtual task run_phase(uvm_phase phase);
  
  phase.raise_objection(this);
  
  trseq.regmodel = e.regmodel;
  trseq.start(e.agent_inst.seqr);
  phase.drop_objection(this);
  
  phase.phase_done.set_drain_time(this, 200);
endtask
endclass
 
//////////////////////////////////////////////////////////////
 
 
module tb;
  
    
  top_if tif();
    
  top dut (tif.clk, tif.rst, tif.wr, tif.addr, tif.din, tif.dout);
 
  
  initial begin
   tif.clk <= 0;
  end
 
  always #10 tif.clk = ~tif.clk;
 
  
  
  initial begin
    uvm_config_db#(virtual top_if)::set(null, "*", "tif", tif);
    
    uvm_config_db#(int)::set(null,"*","include_coverage", 0); //to remove include coverage message
 
    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");`include "uvm_macros.svh"
import uvm_pkg::*;
 
/////////////////////////////////////////////////
///////////////////transaction 
 
class transaction extends uvm_sequence_item;
`uvm_object_utils(transaction)
  
  rand bit wr;
  rand bit [3:0] addr;
  rand bit [7:0] din;
       bit [7:0] dout;
        
   function new(input string path = "transaction");
    super.new(path);
   endfunction
 
 
endclass
 
///////////////////////////////////////////////////////////
/////////////////driver code
 
class drv extends uvm_driver#(transaction);
  `uvm_component_utils(drv)
 
  transaction tr;
  virtual top_if vif;
 
  function new(input string path = "drv", uvm_component parent = null);
    super.new(path,parent);
  endfunction
 
  virtual function void build_phase(uvm_phase phase);
  super.build_phase(phase);
    if(!uvm_config_db#(virtual top_if)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
  endfunction
  
   virtual task run_phase(uvm_phase phase);
      tr = transaction::type_id::create("tr");
     forever begin
        seq_item_port.get_next_item(tr);
               if(tr.wr == 1'b1)
                    begin
                    @(posedge vif.clk);
                    vif.wr   <= tr.wr;
                    vif.addr <= tr.addr;
                    vif.din  <= tr.din;
      `uvm_info("DRV", $sformatf("wr : %0b  addr : %0d  din : %0d dout : %0d", tr.wr, tr.addr, tr.din, tr.dout), UVM_NONE);
        
                   repeat(2) @(posedge vif.clk);  
                    end
                else
                  begin
                    @(posedge vif.clk);
                    vif.wr   <= tr.wr;
                    vif.addr <= tr.addr;
                    @(posedge vif.clk);
      `uvm_info("DRV", $sformatf("wr : %0b  addr : %0d  din : %0d dout : %0d", tr.wr, tr.addr, tr.din, vif.dout), UVM_NONE);
                    tr.dout   = vif.dout;
                     @(posedge vif.clk);
                   end
      seq_item_port.item_done();
      
      end
   endtask
 
 
endclass
 
///////////////////////////////////////////////////////////////////////////////
      
class monitor extends uvm_monitor;
    `uvm_component_utils( monitor )
 
    uvm_analysis_port   #(transaction)  mon_ap;
    virtual top_if vif;
    transaction tr;
    
 
  
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase (phase);
        mon_ap = new("mon_ap", this);
      
    if(!uvm_config_db#(virtual top_if)::get(this,"","vif",vif))//uvm_test_top.env.agent.drv.aif
      `uvm_error("drv","Unable to access Interface");
      
    endfunction : build_phase
  
  
    
  
    function new(string name="my_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new
  
  
  
  
  
    virtual task run_phase(uvm_phase phase);
     tr = transaction::type_id::create("tr");
            forever begin
              repeat(3) @(posedge vif.clk);
                  tr.wr    = vif.wr;
                  tr.addr  = vif.addr;
                  tr.din   = vif.din;
                  tr.dout  = vif.dout;
                  
                         
                  `uvm_info("MON", $sformatf("Wr :%0b  Addr : %0d Din:%0d  Dout:%0d", tr.wr, tr.addr, tr.din, tr.dout), UVM_NONE)
                  mon_ap.write(tr);
                end 
    endtask 
 
      
endclass
 
//////////////////////////////////////////////////////////////////////////////////////////////
 
 
 class sco extends uvm_scoreboard;
`uvm_component_utils(sco)
 
  uvm_analysis_imp#(transaction,sco) recv;
   bit [7:0] arr [16]; 
 
    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
    
  virtual function void write(transaction tr);
    `uvm_info("SCO", $sformatf("Wr :%0b  Addr : %0d Din:%0d  Dout:%0d", tr.wr, tr.addr, tr.din, tr.dout), UVM_NONE)                   if(tr.wr == 1'b1)
        begin
          arr[tr.addr] = tr.din;
          `uvm_info("SCO", $sformatf("Data Stored -> addr : %0d data : %0d", tr.addr, tr.din), UVM_NONE);             
        end
    else
       begin
         if(arr[tr.addr] == tr.dout)
           `uvm_info("SCO","Test Passed", UVM_NONE)
         else
           `uvm_info("SCO","Test Failed", UVM_NONE)
       end
           
   $display("---------------------------------------------");          
  endfunction
 
endclass      
      
      
 
 
//////////////////////////////////////////////////////////////////////////////////////
 
class agent extends uvm_agent;
`uvm_component_utils(agent)
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 drv d;
 uvm_sequencer#(transaction) seqr;
 monitor m;
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
 
 d = drv::type_id::create("d",this); 
 seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); 
 m = monitor::type_id::create("m",this);
  
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
d.seq_item_port.connect(seqr.seq_item_export);
endfunction
 
endclass
 
///////////////////////////////////////////////////////////////////////
///////////////adding memory in verif env
 
 
class dut_mem extends uvm_mem;
`uvm_object_utils(dut_mem)
      
  
 
function new(string name = "dut_mem");
  super.new(name, 16, 8, "RW", UVM_NO_COVERAGE);
endfunction
 
endclass
 
/////////////////////////////////////////////////
 
 
class top_mem_block extends uvm_reg_block;
  `uvm_object_utils(top_mem_block)
  
 
  dut_mem	mem; 
  
 
  function new (string name = "top_mem_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction
 
 
  function void build;
    
      add_hdl_path("dut", "RTL");
    
      mem = new("mem");
      mem.add_hdl_path_slice("mem", 0, 8);
      mem.configure( .parent(this) );
      mem.set_coverage(UVM_NO_COVERAGE);
 
 
    default_map = create_map("reg_map", 0, 1, UVM_LITTLE_ENDIAN, 1); // name, base, nBytes
    default_map.add_mem(mem	, 'h0);  // reg, offset, access
    
    lock_model();
  endfunction
endclass
 
//////////////////////////////////////////////////////////////////
 
////////////////////////////////////////////////////////////////////
         
         
         
class top_reg_seq extends uvm_sequence;
  `uvm_object_utils(top_reg_seq)
  
   top_mem_block regmodel;
  
  
   
  function new (string name = "top_reg_seq"); 
    super.new(name);    
  endfunction
  
  
  task body;
     uvm_status_e   status;
    
    uvm_reg_data_t burst_data[];
    
     burst_data = new[4];
    
    
    
    
    for (int i = 0; i < 4; i++) begin
      burst_data[i] = $urandom_range(50, 255);
    end
    
    
  ////////burst write to memory  
    regmodel.mem.burst_write(status, .offset(regmodel.mem.get_offset),  .value(burst_data), .path(UVM_FRONTDOOR), .parent(this));
    
   ////// burst read from memory  
    regmodel.mem.burst_read(status,  .offset(regmodel.mem.get_offset),  .value(burst_data), .path(UVM_FRONTDOOR), .parent(this));
 
    
  endtask
 
  
  /*
  task body;  
    uvm_status_e   status;
    bit [7:0] rdata,data;
    bit [7:0] arr_wr[10] = '{default : 0};
    bit [7:0] arr_rd[10] = '{default : 0};
    
    
    for(int i = 0; i < 10; i++) 
      begin
        data = $urandom_range(5, 255);
        regmodel.mem.write(status, i , data);
        arr_wr[i] = data;
        $display("-----------------------------------------");
      end
    
    for(int i = 0; i < 10; i++) 
      begin
        regmodel.mem.read(status, i , rdata);
        arr_rd[i] = rdata;
        $display("-----------------------------------------");
      end
    
   // regmodel.mem.write(status,'h0,  8'h4);
   // regmodel.mem.read(status,'h0,  rdata);
   // `uvm_info("SEQ", $sformatf("Data read : %0d", rdata), UVM_NONE);
    
   // regmodel.mem.poke(status,'h1,  8'h12);
   // regmodel.mem.peek(status,'h1,  rdata);
   // `uvm_info("SEQ", $sformatf("Data read : %0d", rdata), UVM_NONE);
    
 
 
 
  
  
  endtask
  
    */
  
  
  
  
endclass
         
        
         
         
         
         
  
  //////////////////////////////////////////////////////////////////////
  
  
  class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils (top_adapter)
 
  //---------------------------------------
  // Constructor 
  //--------------------------------------- 
  function new (string name = "top_adapter");
      super.new (name);
   endfunction
    
    
  
  //---------------------------------------
  // reg2bus method 
  //--------------------------------------- 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;    
    tr = transaction::type_id::create("tr");
    
    if(rw.kind == (UVM_WRITE | UVM_BURST_WRITE))
      tr.wr = 1'b1;
    else if (rw.kind == UVM_READ | UVM_BURST_READ)
      tr.wr = 1'b0;
    
    //tr.wr    = (rw.kind == UVM_WRITE )? 1'b1 : 1'b0;
    
    
    tr.addr  = rw.addr;
    
    if(tr.wr == 1'b1) tr.din = rw.data;
    
    return tr;
    
  endfunction
 
    
    
  //---------------------------------------
  // bus2reg method 
  //--------------------------------------- 
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    transaction tr;
    
    assert($cast(tr, bus_item));
 
    rw.kind = tr.wr ? UVM_WRITE : UVM_READ;
    rw.data = tr.dout;
    rw.addr = tr.addr;
    rw.status = UVM_IS_OK;
  endfunction
endclass
 
  
  /////////////////////////////////////////////////////
  
  
  class env extends uvm_env;
  
  agent          agent_inst;
  top_mem_block  regmodel;   
  top_adapter    adapter_inst;
  sco s;
    
      
  `uvm_component_utils(env)
  
  //--------------------------------------- 
  // constructor
  //---------------------------------------
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
  //---------------------------------------
  // build_phase - create the components
  //---------------------------------------
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    
    s = sco::type_id::create("s", this);
  
 
    agent_inst = agent::type_id::create("agent_inst", this);
    regmodel   = top_mem_block::type_id::create("regmodel", this);
    regmodel.build();
     
    
    adapter_inst = top_adapter::type_id::create("adapter_inst",, get_full_name());
  endfunction 
  
 
  function void connect_phase(uvm_phase phase);
    agent_inst.m.mon_ap.connect(s.recv);
  
    regmodel.default_map.set_sequencer( .sequencer(agent_inst.seqr), .adapter(adapter_inst) );
    regmodel.default_map.set_base_addr(0);        
  endfunction 
 
endclass
 
//////////////////////////////////////////////////////////////////////////////////////////////////
 
 
class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
top_reg_seq trseq;
 
 
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
   trseq  = top_reg_seq::type_id::create("trseq");
endfunction
 
virtual task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  assert(trseq.randomize());
  trseq.regmodel = e.regmodel;
  trseq.start(e.agent_inst.seqr);
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this, 50);
endtask
  
  
  
endclass
 
//////////////////////////////////////////////////////////////
 
 
module tb;
  
    
    
  top_if vif();
    
  top dut (vif.clk, vif.wr, vif.addr, vif.din, vif.dout);
 
  
  initial begin
   vif.clk <= 0;
  end
 
  always #10 vif.clk = ~vif.clk;
 
  
  
  initial begin
    uvm_config_db#(virtual top_if)::set(null, "*", "vif", vif);
    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
 
  
endmodule

         module top (
input clk, wr,
input [3:0] addr,
input [7:0] din,
output reg [7:0] dout  
);
 
  reg [7:0] mem [16];
 
  ///first 4 locations store commands
  /// rest 12 locations store data
 
 
 
  always@(posedge clk)
    begin
      if(wr)
        mem[addr] <= din;
      else
        dout      <= mem[addr];
    end
 
 
endmodule
 
//////////////////////////////interface
 
 
interface top_if;
  logic clk, wr;
  logic [3:0] addr;
  logic [7:0] din;
  logic [7:0] dout ;
  
  
  
  
endinterface


         /////final code

module top 
(  
    input               pclk,
    input               presetn,
    input   [31 : 0]    paddr,
    input   [31 : 0]    pwdata,
    input               psel,
    input               pwrite,
    input               penable,
    output  [31 : 0]    prdata
);
 
  reg [3:0]  cntrl = 0; ///   cntrl :  [reg4 reg3 reg2 reg1]
  reg [31:0] reg1  = 0; //    datainput 1
  reg [31:0] reg2  = 0; ///   datainput 2
  reg [31:0] reg3  = 0; ///   datainput 3
  reg [31:0] reg4  = 0; //    datainput 4
  
    
  reg     [31 : 0]    rdata_tmp = 0;
    
 
    
    // Set all registers to default values
    always @ (posedge pclk) 
      begin
        if( !presetn ) 
        begin
           cntrl    <= 4'b0000;
           reg1     <= 32'h00000000;
           reg2     <= 32'h00000000;
           reg3     <= 32'h00000000;
           reg4     <= 32'h00000000;
          rdata_tmp <= 32'h00000000;
        end
      ////////////write data to registers
        else if( psel && penable && pwrite )
        begin
            case( paddr )
                'h0     : cntrl <= pwdata;
                'h4     : reg1  <= pwdata;
                'h8     : reg2  <= pwdata;
                'hc     : reg3  <= pwdata;
                'h10    : reg4  <= pwdata;
            endcase
        end
        ///////////read data from registers
        else if (psel && penable && !pwrite )
         begin
           case( paddr )
                'h0     : rdata_tmp <= {28'h0000000,cntrl};
                'h4     : rdata_tmp <= reg1;
                'h8     : rdata_tmp <= reg2;
                'hc     : rdata_tmp <= reg3;
                'h10    : rdata_tmp <= reg4;
                default : rdata_tmp <= 32'h00000000;
            endcase
 
         end
      
    end
  
  
assign prdata =  rdata_tmp;
 
endmodule
 
 
 
 
/////////////////////interface
 
 
interface top_if ();
 
    logic   [31 : 0]    paddr;
    logic   [31 : 0]    pwdata;
    logic   [31 : 0]    prdata;
    logic               pwrite;
    logic               psel;
    logic               penable;
    logic               presetn;
    logic               pclk;
 
endinterface
 
 
 
 
 
 
 
 
 
 
 
 
/////////////////////////////////////////////////////////////////////////////////////////////////
 
`include "uvm_macros.svh"
import uvm_pkg::*;
 
///////////////////transaction class
 
 
class transaction extends uvm_sequence_item;
  `uvm_object_utils( transaction )
    rand    bit     [31 : 0]    paddr;
    rand    bit     [31 : 0]    pwdata;
            bit     [31 : 0]    prdata;
    rand    bit                 pwrite;
  
   
  
    function new(string name = "transaction");
       super.new(name);
    endfunction 
  
    constraint c_paddr { 
      paddr inside {0, 4, 8, 12, 16};
    }
 
endclass 
 
 
 
//////////////////////////////////////////
 
class driver extends uvm_driver #(transaction);
    `uvm_component_utils(driver)
  
  
  virtual top_if vif;
  transaction tr;
  
  
  function new(string name = "driver", uvm_component parent = null);
        super.new(name, parent);
   endfunction  
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
      if(!uvm_config_db#(virtual top_if)::get(this, "", "vif", vif))
        `uvm_error("DRV", "Error getting Interface Handle")
    endfunction 
        
        /////write data to dut  -> psel -> pen 
        
    virtual task write();
        @(posedge vif.pclk);
        vif.paddr   <= tr.paddr;
        vif.pwdata  <= tr.pwdata;
        vif.pwrite  <= 1'b1;
        vif.psel    <= 1'b1;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        `uvm_info("DRV", $sformatf("Mode : Write WDATA : %0d ADDR : %0d", vif.pwdata, vif.paddr), UVM_NONE);         
         @(posedge vif.pclk);
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
    endtask 
      
     ////read data from dut 
    virtual task read();
        @(posedge vif.pclk);
        vif.paddr   <= tr.paddr;
        vif.pwrite  <= 1'b0;
        vif.psel    <= 1'b1;
        @(posedge vif.pclk);
        vif.penable <= 1'b1;
        `uvm_info("DRV", $sformatf("Mode : Read WDATA : %0d ADDR : %0d RDATA : %0d", vif.pwdata, vif.paddr, vif.prdata), UVM_NONE);
        @(posedge vif.pclk);
        vif.psel    <= 1'b0;
        vif.penable <= 1'b0;
        tr.prdata   = vif.prdata;
      
 
    endtask 
      
    /////////////////////////////////////////
      
    virtual task run_phase (uvm_phase phase);
        bit [31:0] data;
        vif.presetn <= 1'b1;
        vif.psel <= 0;
        vif.penable <= 0;
        vif.pwrite <= 0;
        vif.paddr <= 0;
        vif.pwdata <= 0;
        forever begin
          seq_item_port.get_next_item (tr);
          if (tr.pwrite)
            begin
               write();
            end
            else 
            begin   
               read();
            end
            seq_item_port.item_done ();
        end
    endtask  
      
  
  
endclass
      
      
      
//////////////////////////////////////////////////////
      
      
class monitor extends uvm_monitor;
    `uvm_component_utils( monitor )
 
    uvm_analysis_port   #(transaction)  mon_ap;
    virtual     top_if              vif;
    
    function new(string name="my_monitor", uvm_component parent);
        super.new(name, parent);
    endfunction : new
  
    virtual function void build_phase(uvm_phase phase);
        super.build_phase (phase);
        mon_ap = new("mon_ap", this);
      if(! uvm_config_db#(virtual top_if)::get (this, "", "vif", vif))
            `uvm_error("DRV", "Error getting Interface Handle")
    endfunction : build_phase
  
    virtual task run_phase(uvm_phase phase);
        fork
            forever begin
               @(posedge vif.pclk);
                if(vif.psel && vif.penable && vif.presetn) begin
                  transaction tr = transaction::type_id::create("tr");
                  tr.paddr  = vif.paddr;
                  tr.pwrite = vif.pwrite;
                    if (vif.pwrite)
                       begin
                        tr.pwdata = vif.pwdata;
                        @(posedge vif.pclk);
                        `uvm_info("MON", $sformatf("Mode : Write WDATA : %0d ADDR : %0d", vif.pwdata, vif.paddr), UVM_NONE);
                       end
                    else
                       begin
                         @(posedge vif.pclk);
                        tr.prdata = vif.prdata;
                        `uvm_info("MON", $sformatf("Mode : Write WDATA : %0d ADDR : %0d RDATA : %0d", vif.pwdata, vif.paddr, vif.prdata), UVM_NONE); 
                       end
                  mon_ap.write(tr);
                end 
            end
        join_none
    endtask 
 
endclass    
///////////////////////////////////////////////////////////////////////////////
      
class sco extends uvm_scoreboard;
`uvm_component_utils(sco)
 
  uvm_analysis_imp#(transaction,sco) recv;
  bit [31:0] arr [17];
  bit [31:0] temp;
 
 
    function new(input string inst = "sco", uvm_component parent = null);
    super.new(inst,parent);
    endfunction
    
    virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    recv = new("recv", this);
    endfunction
    
    
  virtual function void write(transaction tr);
    
    if(tr.pwrite == 1'b1)
      begin
        arr[tr.paddr] = tr.pwdata;
        `uvm_info("SCO", $sformatf("DATA Stored Addr : %0d Data :%0d", tr.paddr, tr.pwdata), UVM_NONE)
      end
    else
       begin
         
         temp = arr[tr.paddr];
         
         if( temp == tr.prdata)
           `uvm_info("SCO", $sformatf("Test Passed -> Addr : %0d Data :%0d", tr.paddr, temp), UVM_NONE)
         else
          `uvm_error("SCO", $sformatf("Test Failed -> Addr : %0d Data :%0d", tr.paddr, temp))
         
       end
       $display("----------------------------------------------------------------");
     
           
           
      endfunction
 
endclass      
      
 /////////////////////////////////////////////////////////////////////////////////////////////////
 
       
 class agent extends uvm_agent;
`uvm_component_utils(agent)
  
 
function new(input string inst = "agent", uvm_component parent = null);
super.new(inst,parent);
endfunction
 
 driver d;
 uvm_sequencer#(transaction) seqr;
 monitor m;
 
 
 
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   d = driver::type_id::create("d",this);
   m = monitor::type_id::create("m",this);
   seqr = uvm_sequencer#(transaction)::type_id::create("seqr", this); 
endfunction
 
virtual function void connect_phase(uvm_phase phase);
super.connect_phase(phase);
   d.seq_item_port.connect(seqr.seq_item_export);
endfunction
 
endclass
 
      /////////////////////////////////////////////     
      
      
///////////////////////////////////////////////////////////////////////////      
/////////////////////implementing RAL model
      
class cntrl_reg extends uvm_reg;
    `uvm_object_utils(cntrl_reg)
    
    rand    uvm_reg_field   cntrl;
  
  
   
    function new(string name = "cntrl_reg");
      super.new(name, 4, build_coverage(UVM_NO_COVERAGE));
    endfunction
   
    virtual function void build();
        cntrl     = uvm_reg_field::type_id::create("cntrl");
        cntrl.configure(this, 4, 0, "RW", 0, 4'h0, 1, 1, 1);
    endfunction 
 
endclass    
      
///////////////////////////////////
      
class reg1_reg extends uvm_reg;
    `uvm_object_utils(reg1_reg)
    
    rand    uvm_reg_field   reg1;
   
    function new(string name = "reg1_reg");
        super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
    endfunction : new
   
    virtual function void build();
        reg1     = uvm_reg_field::type_id::create("reg1");
        reg1.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction 
 
endclass       
      
///////////////////////////////////
      
class reg2_reg extends uvm_reg;
  `uvm_object_utils(reg2_reg)
    
    rand    uvm_reg_field   reg2;
   
  function new(string name = "reg2_reg");
        super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
    endfunction : new
   
    virtual function void build();
        reg2     = uvm_reg_field::type_id::create("reg2");
        reg2.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction 
 
endclass   
      
//////////////////////////////////////////////      
class reg3_reg extends uvm_reg;
  `uvm_object_utils(reg3_reg)
    
    rand    uvm_reg_field   reg3;
   
  function new(string name = "reg3_reg");
        super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
    endfunction : new
   
    virtual function void build();
      reg3     = uvm_reg_field::type_id::create("reg3");
        reg3.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction 
 
endclass  
      
//////////////////////////////////////////////      
 class reg4_reg extends uvm_reg;
   `uvm_object_utils(reg4_reg)
    
    rand    uvm_reg_field   reg4;
   
   function new(string name = "reg4_reg");
        super.new(name, 32, build_coverage(UVM_NO_COVERAGE));
    endfunction : new
   
    virtual function void build();
      reg4     = uvm_reg_field::type_id::create("reg4");
        reg4.configure(this, 32, 0, "RW", 0, 32'h0, 1, 1, 1);
    endfunction 
 
endclass   
      
//////////////////////////////////////////////      
                 
      
class reg_block extends uvm_reg_block;
    `uvm_object_utils(reg_block)  
  
  cntrl_reg cntrl_inst;
  reg1_reg  reg1_inst;
  reg2_reg  reg2_inst;
  reg3_reg  reg3_inst;
  reg4_reg  reg4_inst;
  
    function new(string name = "reg_block");
        super.new(name, build_coverage(UVM_NO_COVERAGE));
    endfunction : new 
  
   virtual function void build();
        default_map = create_map("default_map", 0, 4, UVM_LITTLE_ENDIAN,0); // name, base, nBytes
        
 
     
         cntrl_inst = cntrl_reg::type_id::create("cntrl_inst");
         cntrl_inst.build();
         cntrl_inst.configure(this,null);
  
 
 
         reg1_inst = reg1_reg::type_id::create("reg1_inst");
         reg1_inst.build();
         reg1_inst.configure(this,null);
     
     
         reg2_inst = reg2_reg::type_id::create("reg2_inst");
         reg2_inst.build();
         reg2_inst.configure(this,null);
     
     
         reg3_inst = reg3_reg::type_id::create("reg3_inst");
         reg3_inst.build();
         reg3_inst.configure(this,null);
     
     
         reg4_inst = reg4_reg::type_id::create("reg4_inst");
         reg4_inst.build();
         reg4_inst.configure(this,null);
     
        default_map.add_reg(cntrl_inst	, 'h0, "RW");  // reg, offset, access
        default_map.add_reg(reg1_inst	, 'h4, "RW");  // reg, offset, access
        default_map.add_reg(reg2_inst	, 'h8, "RW");  // reg, offset, access
        default_map.add_reg(reg3_inst	, 'hc, "RW");  // reg, offset, access
        default_map.add_reg(reg4_inst	, 'h10, "RW");  // reg, offset, access
        lock_model();
     
    endfunction 
  
  
endclass
      
      
      
 ///////////////////////////////////adapter
      
      
 class top_adapter extends uvm_reg_adapter;
  `uvm_object_utils (top_adapter)
 
 
  function new (string name = "top_adapter");
      super.new (name);
   endfunction
  
 
  function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
    transaction tr;    
    tr = transaction::type_id::create("tr");
    
    tr.pwrite    = (rw.kind == UVM_WRITE) ? 1'b1 : 1'b0;
    tr.paddr     = rw.addr;
    tr.pwdata    = rw.data;
 
 
    return tr;
  endfunction
 
 
   
  function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
    transaction tr;
    
    assert($cast(tr, bus_item));
 
    rw.kind = (tr.pwrite == 1'b1) ? UVM_WRITE : UVM_READ;
    rw.data = (tr.pwrite == 1'b1) ? tr.pwdata : tr.prdata;
    rw.addr = tr.paddr;
    rw.status = UVM_IS_OK;
  endfunction
endclass
     
////////////////////////////////////////////////////////////////////////////////////////////////////      
 
      
      
 class env extends uvm_env;
  `uvm_component_utils(env)
  
  agent          agent_inst;
  reg_block  regmodel;   
  top_adapter    adapter_inst;
  uvm_reg_predictor   #(transaction)  predictor_inst;
   
  sco s; 
  
 
 
  function new(string name = "env", uvm_component parent);
    super.new(name, parent);
  endfunction : new
 
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent_inst = agent::type_id::create("agent_inst", this);
    s = sco::type_id::create("s", this);
    
    regmodel   = reg_block::type_id::create("regmodel", this);
    regmodel.build();
 
   
    predictor_inst = uvm_reg_predictor#(transaction)::type_id::create("predictor_inst", this);
    adapter_inst = top_adapter::type_id::create("adapter_inst",, get_full_name());
    
  endfunction 
  
 
  function void connect_phase(uvm_phase phase);
    agent_inst.m.mon_ap.connect(s.recv);
    agent_inst.m.mon_ap.connect(predictor_inst.bus_in);
    
    regmodel.default_map.set_sequencer( .sequencer(agent_inst.seqr), .adapter(adapter_inst) );
    regmodel.default_map.set_base_addr(0);
    
    predictor_inst.map       = regmodel.default_map;
    predictor_inst.adapter   = adapter_inst;
  endfunction 
 
endclass    
      
 /////////////////////////////////////////////////
 //////////////////write data to control reg     
      
 class ctrl_wr extends uvm_sequence;
 
  `uvm_object_utils(ctrl_wr)
  
   reg_block regmodel;
 
   
  function new (string name = "ctrl_wr"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [3:0] wdata; 
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
       wdata = $urandom();
       regmodel.cntrl_inst.write(status, wdata);
    end
    
  endtask
  
  
endclass
  
/////////////////////////////////////////////////////////////////////////
 //////////////////read data from control reg     
        
       
 class ctrl_rd extends uvm_sequence;
 
  `uvm_object_utils(ctrl_rd)
  
   reg_block regmodel;
  
   
  function new (string name = "ctrl_rd"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [3:0] rdata;
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
     regmodel.cntrl_inst.read(status, rdata); 
    end
    
 
 
  endtask
  
  
  
endclass        
         
         
 /////////////////////////////////////////////////
 //////////////////write data to reg1 reg     
      
 class reg1_wr extends uvm_sequence;
 
  `uvm_object_utils(reg1_wr)
  
   reg_block regmodel;
  
   
  function new (string name = "reg1_wr"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] wdata; 
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
       wdata = $urandom();
       regmodel.reg1_inst.write(status, wdata);
    end
    
  endtask
  
  
endclass
  
/////////////////////////////////////////////////////////////////////////
 //////////////////read data from control reg     
        
       
 class reg1_rd extends uvm_sequence;
 
  `uvm_object_utils(reg1_rd)
  
   reg_block regmodel;
  
   
  function new (string name = "reg1_rd"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] rdata;
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
     regmodel.reg1_inst.read(status, rdata); 
    end
    
 
 
  endtask
  
  
  
endclass        
                  
///////////////////////////////////////////////////////////////         
         
  /////////////////////////////////////////////////
 //////////////////write data to reg2 reg     
      
 class reg2_wr extends uvm_sequence;
 
  `uvm_object_utils(reg2_wr)
  
   reg_block regmodel;
  
   
  function new (string name = "reg2_wr"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] wdata; 
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
       wdata = $urandom();
       regmodel.reg2_inst.write(status, wdata);
    end
    
  endtask
  
  
endclass
  
/////////////////////////////////////////////////////////////////////////
 //////////////////read data from control reg     
        
       
 class reg2_rd extends uvm_sequence;
 
  `uvm_object_utils(reg2_rd)
  
   reg_block regmodel;
  
   
  function new (string name = "reg2_rd"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] rdata;
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
     regmodel.reg2_inst.read(status, rdata); 
    end
    
 
 
  endtask
  
  
  
endclass           
//////////////////////////////////////////////////////////////////////         
         
         
  /////////////////////////////////////////////////
 //////////////////write data to reg3 reg     
      
 class reg3_wr extends uvm_sequence;
 
  `uvm_object_utils(reg3_wr)
  
   reg_block regmodel;
  
   
  function new (string name = "reg3_wr"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] wdata; 
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
       wdata = $urandom();
       regmodel.reg3_inst.write(status, wdata);
    end
    
  endtask
  
  
endclass
  
/////////////////////////////////////////////////////////////////////////
 //////////////////read data from control reg     
        
       
 class reg3_rd extends uvm_sequence;
 
  `uvm_object_utils(reg3_rd)
  
   reg_block regmodel;
  
   
  function new (string name = "reg3_rd"); 
    super.new(name);    
  endfunction
  
 
  task body;  
    uvm_status_e   status;
    bit [31:0] rdata;
    
    //////working with control 
    for(int i = 0; i < 5 ; i++) begin
     regmodel.reg3_inst.read(status, rdata); 
    end
    
 
 
  endtask
  
  
  
endclass           
//////////////////////////////////////////////////////////////////////           
//////////////////////////////////////////////////////////////////////
      
 class test extends uvm_test;
`uvm_component_utils(test)
 
function new(input string inst = "test", uvm_component c);
super.new(inst,c);
endfunction
 
env e;
ctrl_wr  cwr;
ctrl_rd  crd;
   
reg1_wr r1wr;
reg1_rd r1rd;
   
reg2_wr r2wr;
reg2_rd r2rd;
 
reg3_wr r3wr;
reg3_rd r3rd;   
  
virtual function void build_phase(uvm_phase phase);
super.build_phase(phase);
   e      = env::type_id::create("env",this);
  
   cwr  = ctrl_wr::type_id::create("cwr");
   crd  = ctrl_rd::type_id::create("crd");
  
   r1wr = reg1_wr::type_id::create("r1wr");
   r1rd = reg1_rd::type_id::create("r1rd");
  
  
  r2wr = reg2_wr::type_id::create("r2wr");
  r2rd = reg2_rd::type_id::create("r2rd");  
 
  
  r3wr = reg3_wr::type_id::create("r3wr");
  r3rd = reg3_rd::type_id::create("r3rd");  
  
endfunction
 
virtual task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  
  cwr.regmodel = e.regmodel;
  cwr.start(e.agent_inst.seqr);
 
  crd.regmodel = e.regmodel;
  crd.start(e.agent_inst.seqr);
 
  
  /*
  assert(r1wr.randomize());
  r1wr.regmodel = e.regmodel;
  r1wr.start(e.agent_inst.seqr);
  
  /////////////////read from control reg
  assert(r1rd.randomize());
  r1rd.regmodel = e.regmodel;
  r1rd.start(e.agent_inst.seqr);
 */
 
  /*
  assert(r2wr.randomize());
  r2wr.regmodel = e.regmodel;
  r2wr.start(e.agent_inst.seqr);
  
  /////////////////read from control reg
  assert(r2rd.randomize());
  r2rd.regmodel = e.regmodel;
  r2rd.start(e.agent_inst.seqr);
 */
  
  
  /*
  assert(r3wr.randomize());
  r3wr.regmodel = e.regmodel;
  r3wr.start(e.agent_inst.seqr);
  
  /////////////////read from control reg
  assert(r3rd.randomize());
  r3rd.regmodel = e.regmodel;
  r3rd.start(e.agent_inst.seqr);
  */
  
  phase.drop_objection(this);
  phase.phase_done.set_drain_time(this, 200);
endtask
endclass
      
      
/////////////////////////////////////////////////////////
      
      
      
module tb;
  
    
    
  top_if vif();
    
  top dut (vif.pclk, vif.presetn, vif.paddr, vif.pwdata, vif.psel, vif.pwrite, vif.penable, vif.prdata);
 
  
  initial begin
   vif.pclk <= 0;
  end
 
  always #10 vif.pclk = ~vif.pclk;
 
  
  
  initial begin
    uvm_config_db#(virtual top_if)::set(null, "*", "vif", vif);
    run_test("test");
   end
  
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
 
  
endmodule

         module top 
(  
    input               pclk,
    input               presetn,
    input   [31 : 0]    paddr,
    input   [31 : 0]    pwdata,
    input               psel,
    input               pwrite,
    input               penable,
    output  [31 : 0]    prdata
);
 
  reg [3:0]  cntrl = 0; ///   cntrl :  [reg4 reg3 reg2 reg1]
  reg [31:0] reg1  = 0; //    datainput 1
  reg [31:0] reg2  = 0; ///   datainput 2
  reg [31:0] reg3  = 0; ///   datainput 3
  reg [31:0] reg4  = 0; //    datainput 4
  
    
  reg     [31 : 0]    rdata_tmp = 0;
    
 
    
    // Set all registers to default values
    always @ (posedge pclk) 
      begin
        if( !presetn ) 
        begin
           cntrl    <= 4'b0000;
           reg1     <= 32'h00000000;
           reg2     <= 32'h00000000;
           reg3     <= 32'h00000000;
           reg4     <= 32'h00000000;
          rdata_tmp <= 32'h00000000;
        end
      ////////////update values of register
        else if( psel && penable && pwrite )
        begin
            case( paddr )
                'h0     : cntrl <= pwdata;
                'h4     : reg1  <= pwdata;
                'h8     : reg2  <= pwdata;
                'hc     : reg3  <= pwdata;
                'h10    : reg4  <= pwdata;
            endcase
        end
        else if (psel && penable && !pwrite )
         begin
           case( paddr )
                'h0     : rdata_tmp <= {28'h0000000,cntrl};
                'h4     : rdata_tmp <= reg1;
                'h8     : rdata_tmp <= reg2;
                'hc     : rdata_tmp <= reg3;
                'h10    : rdata_tmp <= reg4;
                default : rdata_tmp <= 32'h00000000;
            endcase
 
         end
      
    end
  
  
assign prdata =  rdata_tmp;
 
endmodule
 
 
 
 
/////////////////////interface
 
 
interface top_if ();
 
    logic   [31 : 0]    paddr;
    logic   [31 : 0]    pwdata;
    logic   [31 : 0]    prdata;
    logic               pwrite;
    logic               psel;
    logic               penable;
    logic               presetn;
    logic               pclk;
 
endinterface
    $dumpvars;
  end
 
  
endmodule
