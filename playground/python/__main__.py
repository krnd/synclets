import importlib
import logging
import sys
from glob import glob
from os.path import basename, dirname, getmtime, join
from typing import Union

from playground.utilities import printutil


__version__ = "2022-06-14"
__description__ = ""

__author__ = "Kilian Kaiping (krnd)"
__copyright__ = "Copyright (c) 2022 Kilian Kaiping (krnd)"
__license__ = "MIT"

__compatibility__ = "3.10"
__dependencies__ = ()
__utilities__ = ()


logging.basicConfig(
    format="[%(levelname)7s] %(message)s <%(name)s|%(module)s:%(lineno)d>",
    level=logging.DEBUG,
)


runner = sys.argv[1] if len(sys.argv) > 1 else None
if runner is None or runner == "??":
    latest_file = max(
        glob(join(dirname(__file__), "runner", "*.py")),
        key=getmtime,
    )
    runner = basename(latest_file)[: -len(".py")]
module = importlib.import_module(f"{__package__}.runner.{runner}")


runargs = dict[str, Union[int, float, str]]()
for arg in sys.argv[2:]:
    name, valuestr = (_str.strip() for _str in arg.split("=", maxsplit=1))
    try:
        value = int(
            valuestr,
            base={
                "0b": 2,
                "0o": 8,
                "0x": 16,
            }.get(valuestr[:1], 10),
        )
    except ValueError:
        try:
            value = float(valuestr)
        except ValueError:
            value = str(valuestr)
    runargs[name] = value


printutil.title(f"{runner}", empty=1)
module.__run__(**runargs)
printutil.separator(empty=1)
printutil.message(f"Runner {runner!r} finished!")
