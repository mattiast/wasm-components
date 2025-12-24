from wasmtime.component import Linker, Component
from wasmtime import Engine, Store

# Create engine and store
engine = Engine()
store = Store(engine)

# Create a linker and define the `square` import
linker = Linker(engine)


def square(store, x: int) -> int:
    return x * x


with linker.root() as root:
    root.add_func("square", square)

# Load and instantiate the component
component = Component.from_file(engine, "sos.c.wasm")
instance = linker.instantiate(store, component)

# Call the exported function
sum_of_squares = instance.get_func(store, "sum-of-squares")
assert sum_of_squares is not None
result = sum_of_squares(store, 3, 4)
if result == 25:
    print("Success: 3^2 + 4^2 = 25")
else:
    print("Failure: unexpected result", result)
