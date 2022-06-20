import functools
from typing import Any, Callable, Final, Literal, ParamSpec, Tuple


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
    "empty",
    "separator",
    "title",
    "subtitle",
    "message",
    "action",
    "value",
    # fmt: on
)


P = ParamSpec("P")


LINE_LENGTH: Final = 60
SHORTLINE_LENGTH: Final = 40

TITLE_ALIGNMENT: Final = 20
SUBTITLE_ALIGNMENT: Final = 10


def empty(lines: int = 1) -> None:
    if lines <= 0:
        return
    _print("\n" * (lines - 1))


print_empty = empty


def empty_wrapper(default: Literal["before", "after"]):
    def empty_wrapper(func: Callable[P, None]) -> Callable[P, None]:
        @functools.wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> None:
            empty: tuple[int, int] | int = kwargs.get("empty", 0)  # type: ignore
            before, after = (
                (
                    (empty if default == "before" else 0),
                    (empty if default == "after" else 0),
                )
                if isinstance(empty, int)
                else empty
            )

            print_empty(lines=before)
            func(*args, **kwargs)
            print_empty(lines=after)

        return wrapper

    return empty_wrapper


@empty_wrapper("before")
def separator(
    width: int | Literal["full", "short"] = "full",
    *,
    empty: tuple[int, int] | int = 0,
) -> None:
    _print(
        "="
        * (
            LINE_LENGTH
            if width == "full"
            else (SHORTLINE_LENGTH if width == "short" else width)
        )
    )


print_separator = separator


@empty_wrapper("after")
def title(text: str, *, empty: tuple[int, int] | int = 0) -> None:
    _print(
        str.rjust(
            "[ ",
            TITLE_ALIGNMENT,
            "=",
        )
        + str.ljust(
            f"{text.upper()} ]",
            LINE_LENGTH - TITLE_ALIGNMENT,
            "=",
        )
    )


print_title = title


@empty_wrapper("after")
def subtitle(
    text: str, *, upper: bool = True, empty: tuple[int, int] | int = 0
) -> None:
    _print(
        str.rjust(
            "[ ",
            SUBTITLE_ALIGNMENT,
            "=",
        )
        + str.ljust(
            f"{text.upper() if upper else text} ]",
            SHORTLINE_LENGTH - SUBTITLE_ALIGNMENT,
            "=",
        )
    )


print_subtitle = subtitle


def message(message: str) -> None:
    _print(message)


print_message = message


def action(name: str, *values: Tuple[str, Any]) -> None:
    _values = str.join(
        ", ",
        (
            f"{_name}={_value}"
            for _name, _value in values
            #
        ),
    )
    _print(f"{name}({_values})")


print_action = action


def value(name: str, value: Any) -> None:
    _print(f"{name} = {value}")


print_value = value


def _print(message: str) -> None:
    print(message)
