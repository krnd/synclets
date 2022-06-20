import os.path
import timeit
from typing import Any, Callable, ClassVar, Dict, Final, Iterable, Tuple


__version__ = "2022-06-14"
__description__ = ""

__author__ = "Kilian Kaiping (krnd)"
__copyright__ = "Copyright (c) 2022 Kilian Kaiping (krnd)"
__license__ = "MIT"

__compatibility__ = "3.10"
__dependencies__ = ()
__utilities__ = ()

__all__ = (
    # fmt: off
    "configure",
    "group",
    # fmt: on
)


MAX_NAME_LENGTH: Final = 12

RESULTS_INDENT: Final = 2


class _stash:
    title_: str = ""
    number: ClassVar[int] = int(1e3)
    globals: ClassVar[dict[str, Any] | None] = None

    @classmethod
    def title(cls, title: str) -> str:
        return f"{cls.title_} [{title}]" if cls.title_ else title


def configure(
    file: str,
    *,
    number: int | float | None = None,
    globals: Dict[str, Any] | None = None,
) -> None:
    _title = os.path.splitext(os.path.basename(file))[0]
    print()
    print("=====", _title, "=====")
    _stash.title_ = _title
    _configure(number, globals)


def group(
    title: str,
    __items: Iterable[Callable[[], Any] | Tuple[str, str]],
    *,
    number: int | float | None = None,
    globals: Dict[str, Any] | None = None,
) -> None:
    print()
    if title:
        print(_stash.title(title))
    _configure(number, globals)

    reference = 0
    for item in __items:
        if callable(item):
            name = item.__name__.strip("_")
            stmt = f"{item.__name__}()"
        else:
            name, stmt = item

        runtime = timeit.timeit(
            stmt,
            number=_stash.number,
            globals=_stash.globals,
        )

        print(
            (" " * (RESULTS_INDENT - 1)),
            name.ljust(MAX_NAME_LENGTH),
            f"{(runtime * 1000):>9.4f} ms",
            " ",
            (
                f"({(runtime / reference * 100):>5.1f}%)"
                if reference
                else "(100.0%)"
            ),
        )

        if not reference:
            reference = runtime


def _configure(
    number: int | float | None = None,
    globals: Dict[str, Any] | None = None,
) -> None:
    if number is not None:
        _stash.number = int(number)
        print(
            (" " * (RESULTS_INDENT - 1)),
            str.ljust(":number:", MAX_NAME_LENGTH),
            f"{float(number):>9g}",
        )

    if globals is not None:
        _stash.globals = globals
        print(
            (" " * (RESULTS_INDENT - 1)),
            str.ljust(":globals:", MAX_NAME_LENGTH),
            f"{'...':>9s}",
        )
