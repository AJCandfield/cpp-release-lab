if(NOT DEFINED EXECUTABLE)
  message(FATAL_ERROR "EXECUTABLE is required")
endif()

if(NOT DEFINED EXPECTED_EXIT)
  message(FATAL_ERROR "EXPECTED_EXIT is required")
endif()

set(arguments)
if(DEFINED CLI_ARGUMENTS)
  list(APPEND arguments ${CLI_ARGUMENTS})
elseif(DEFINED CLI_ARGUMENT)
  list(APPEND arguments "${CLI_ARGUMENT}")
endif()

execute_process(
  COMMAND "${EXECUTABLE}" ${arguments}
  RESULT_VARIABLE actual_exit
  OUTPUT_VARIABLE actual_stdout
  ERROR_VARIABLE actual_stderr
)

function(normalize_output variable)
  string(REPLACE "\r\n" "\n" normalized "${${variable}}")
  string(REPLACE "\r" "\n" normalized "${normalized}")
  set(${variable} "${normalized}" PARENT_SCOPE)
endfunction()

normalize_output(actual_stdout)
normalize_output(actual_stderr)

if(NOT "${actual_exit}" STREQUAL "${EXPECTED_EXIT}")
  message(FATAL_ERROR "Expected exit ${EXPECTED_EXIT}, got ${actual_exit}")
endif()

if(DEFINED EXPECTED_STDOUT)
  normalize_output(EXPECTED_STDOUT)
  if(NOT actual_stdout STREQUAL EXPECTED_STDOUT)
    message(FATAL_ERROR "Expected stdout '${EXPECTED_STDOUT}', got '${actual_stdout}'")
  endif()
elseif(NOT actual_stdout STREQUAL "")
  message(FATAL_ERROR "Expected empty stdout, got '${actual_stdout}'")
endif()

if(DEFINED EXPECTED_STDERR)
  normalize_output(EXPECTED_STDERR)
  if(NOT actual_stderr STREQUAL EXPECTED_STDERR)
    message(FATAL_ERROR "Expected stderr '${EXPECTED_STDERR}', got '${actual_stderr}'")
  endif()
elseif(NOT actual_stderr STREQUAL "")
  message(FATAL_ERROR "Expected empty stderr, got '${actual_stderr}'")
endif()
