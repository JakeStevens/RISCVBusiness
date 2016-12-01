Adding a New Module of a Configurable Component:

1. Create the new module inside the folder for that component
2. Use the proper interface for that component
3. Add the new module to the case structure for the generic component
within standard_core/

Adding a New Configurable Component Type:

1. Create a directory within source_code/ for the compmonent
2. Add this new directory to the src_dir array for RISCVBusiness and 
RISCVBusiness_self_test inside source_code/wscript
3. Create a version of the nonconfigurable component in the new directory
4. Create a configurable component in source_code/standard_code
(See source_code/standard_core/branch_predictor.sv for an example)
5. Use the previously nonconfigurable component as the default
6. Pass parameters down module to module from RISCVBusiness to the component
7. Add the parameter to source_code/include/component_selection_defines.vh


Note: These steps are a general guideline. For example, the caches module
inside source_code/standard_core is a configurable module that chooses the
icache/dcache arrangement (e.g. separate or unified). But, the separate_caches
module inside source_code/caches is also a configurable component that only
follows steps 6 & 7, as these are the bare minimum steps needed. This makes
the caches component in the standard_core a two-tiered configurable component. 
