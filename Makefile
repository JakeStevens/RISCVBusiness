ROOT := $(shell pwd)

RISCV := $(ROOT)/source_code
RISCV_CORE := $(RISCV)/standard_core
PIPELINE := $(RISCV)/pipelines
RISCV_PKGS := $(RISCV)/packages
RISC_MGMT := $(RISCV)/risc_mgmt
SPARCE := $(RISCV)/sparce
PRIVS := $(RISCV)/privs
BRANCH_PREDICT := $(RISCV)/branch_predictors
CACHES := $(RISCV)/caches
RISCV_BUS := $(RISCV)/bus_bridges
RV32C := $(RISCV)/rv32c
RV32M_FILES := $(RISC_MGMT)/extensions/rv32m/carry_save_adder.sv $(RISC_MGMT)/extensions/rv32m/flex_counter_mul.sv $(RISC_MGMT)/extensions/rv32m/full_adder.sv $(RISC_MGMT)/extensions/rv32m/pp_mul32.sv $(RISC_MGMT)/extensions/rv32m/radix4_divider.sv $(RISC_MGMT)/extensions/rv32m/rv32m_decode.sv $(RISC_MGMT)/extensions/rv32m/rv32m_execute.sv $(RISC_MGMT)/extensions/rv32m/rv32m_memory.sv
RV32C_FILES := $(RV32C)/decompressor.sv $(RV32C)/fetch_buffer.sv $(RV32C)/rv32c_disabled.sv $(RV32C)/rv32c_enabled.sv $(RV32C)/rv32c_wrapper.sv
RISC_MGMT_FILES := $(RISC_MGMT)/risc_mgmt_wrapper.sv $(RISC_MGMT)/tspp/tspp_risc_mgmt.sv $(RV32M_FILES)
RISC_EXT_FILES := $(RISC_MGMT)/extensions/template/template_decode.sv $(RISC_MGMT)/extensions/template/template_execute.sv $(RISC_MGMT)/extensions/template/template_memory.sv
CORE_PKG_FILES := $(RISCV_PKGS)/rv32i_types_pkg.sv $(RISCV_PKGS)/alu_types_pkg.sv $(RISCV_PKGS)/risc_mgmt/template_pkg.sv $(RISCV_PKGS)/risc_mgmt/crc32_pkg.sv $(RISCV_PKGS)/risc_mgmt/rv32m_pkg.sv $(RISCV_PKGS)/risc_mgmt/test_pkg.sv $(RISCV_PKGS)/machine_mode_types_1_12_pkg.sv $(RISCV_PKGS)/machine_mode_types_pkg.sv
CORE_FILES := $(RISCV_CORE)/alu.sv  $(RISCV_CORE)/branch_res.sv  $(RISCV_CORE)/control_unit.sv  $(RISCV_CORE)/dmem_extender.sv  $(RISCV_CORE)/endian_swapper.sv  $(RISCV_CORE)/jump_calc.sv  $(RISCV_CORE)/memory_controller.sv  $(RISCV_CORE)/RISCVBusiness.sv  $(RISCV_CORE)/rv32i_reg_file.sv $(RISCV_CORE)/top_core.sv
PIPELINE_FILES :=  $(PIPELINE)/tspp/tspp_execute_stage.sv  $(PIPELINE)/tspp/tspp_fetch_stage.sv  $(PIPELINE)/tspp/tspp_hazard_unit.sv  #$(PIPELINE)/tspp/tspp.sv
PREDICTOR_FILES := $(BRANCH_PREDICT)/branch_predictor_wrapper.sv $(BRANCH_PREDICT)/nottaken_predictor/nottaken_predictor.sv
PRIV_FILES := $(PRIVS)/priv_wrapper.sv  $(PRIVS)/priv_1_12/priv_1_12_block.sv  $(PRIVS)/priv_1_12/priv_1_12_int_ex_handler.sv  $(PRIVS)/priv_1_12/priv_1_12_csr.sv  $(PRIVS)/priv_1_12/priv_1_12_pipe_control.sv
CACHE_FILES := $(CACHES)/caches_wrapper.sv $(CACHES)/pass_through/pass_through_cache.sv $(CACHES)/direct_mapped_tpf/direct_mapped_tpf_cache.sv $(CACHES)/separate_caches.sv
SPARCE_FILES := $(SPARCE)/sparce_wrapper.sv $(SPARCE)/sparce_disabled/sparce_disabled.sv $(SPARCE)/sparce_enabled/sparce_cfid.sv  $(SPARCE)/sparce_enabled/sparce_enabled.sv  $(SPARCE)/sparce_enabled/sparce_psru.sv  $(SPARCE)/sparce_enabled/sparce_sasa_table.sv  $(SPARCE)/sparce_enabled/sparce_sprf.sv  $(SPARCE)/sparce_enabled/sparce_svc.sv
RISCV_BUS_FILES := $(RISCV_BUS)/generic_nonpipeline.sv #$(RISCV_BUS)/ahb.sv
TRACKER_FILES := $(RISCV)/trackers/cpu_tracker.sv $(RISCV)/trackers/branch_tracker.sv

COMPONENT_FILES_SV := $(CORE_PKG_FILES) $(RISC_MGMT_FILES) $(RISC_EXT_FILES) $(CORE_FILES) $(RV32C_FILES) $(PIPELINE_FILES) $(SPARCE_FILES) $(PREDICTOR_FILES) $(PRIV_FILES) $(CACHE_FILES) $(RISCV_BUS_FILES) $(TRACKER_FILES)

TOP_ENTITY := RISCVBusiness

HEADER_FILES := -I$(RISCV)/include


define USAGE
@echo "-----------------------------------------"
@echo " Build Targets:"
@echo "     config: config core with example.yml"
@echo "     verilate: Invoke verilator"
@echo "-----------------------------------------"
endef

.phony: default clean


default:
	$(USAGE)

config:
	python3 scripts/config_core.py example.yml

verilate:
	verilator -Wno-UNOPTFLAT -Wno-SYMRSVDWORD -cc -Wno-lint --report-unoptflat --trace-fst --trace-structs --top-module top_core $(HEADER_FILES) $(COMPONENT_FILES_SV) --exe tb_core.cc
	$(MAKE) -C obj_dir -f Vtop_core.mk -j `nproc`

clean:
	rm -rf obj_dir
