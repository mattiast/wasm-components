import os

import pytest
from wasmtime import Engine, Store
from wasmtime.component import Component, Linker

COMPONENT_PATH = os.environ.get(
    "SOS_COMPONENT", os.path.join(os.path.dirname(__file__), "sos.c.wasm")
)


@pytest.fixture
def logs():
    return []


@pytest.fixture
def sos(logs):
    engine = Engine()
    store = Store(engine)
    linker = Linker(engine)

    def square(store, x: int) -> int:
        return x * x

    def log(store, level, msg: str) -> None:
        logs.append((level, msg))

    with linker.root() as root:
        root.add_func("square", square)
        with root.add_instance("foo:bar/logger") as logger:
            logger.add_func("log", log)

    component = Component.from_file(engine, COMPONENT_PATH)
    instance = linker.instantiate(store, component)
    func = instance.get_func(store, "sum-of-squares")
    assert func is not None
    return lambda x, y: func(store, x, y)


@pytest.mark.parametrize(
    "x, y, expected",
    [(3, 4, 25), (0, 0, 0), (1, 2, 5), (10, 20, 500)],
)
def test_sum_of_squares(sos, x, y, expected):
    assert sos(x, y) == expected


def test_logs_squares(sos, logs):
    sos(3, 4)
    assert [msg for _, msg in logs] == ["Squared x: 9", "Squared y: 16"]
