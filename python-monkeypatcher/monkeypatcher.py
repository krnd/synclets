# type: ignore
# flake8: noqa

import sys


# ################################ PREFACE #####################################


if sys.version_info < (3, 9):
    raise NotImplementedError(
        "Python version "
        + str(sys.version_info.major)
        + "."
        + str(sys.version_info.minor)
        + " is not supported.",
        __name__,
        __file__,
    )


# ################################ PATCHER #####################################


def patch_dataclasses(*, weakref_slot=False, **args):
    import dataclasses

    if sys.version_info < (3, 10):

        # fmt: off

        def dataclass(cls=None, /, *, init=True, repr=True, eq=True, order=False, unsafe_hash=False, frozen=False, match_args=True, kw_only=False, slots=False, weakref_slot=False):
            def wrap(cls):
                return dataclasses._process_class(cls, init, repr, eq, order, unsafe_hash, frozen)
            if cls is None:
                return wrap
            return wrap(cls)

        # fmt: on

        setattr(
            dataclasses,
            "dataclass",
            dataclass,
        )

    elif weakref_slot and sys.version_info < (3, 11):

        # fmt: off

        def dataclass(cls=None, /, *, init=True, repr=True, eq=True, order=False, unsafe_hash=False, frozen=False, match_args=True, kw_only=False, slots=False, weakref_slot=False):
            def wrap(cls):
                return dataclasses._process_class(cls, init, repr, eq, order, unsafe_hash, frozen, match_args, kw_only, slots)
            if cls is None:
                return wrap
            return wrap(cls)

        # fmt: on

        setattr(
            dataclasses,
            "dataclass",
            dataclass,
        )

    if sys.version_info < (3, 10):

        # fmt: off

        def field(*, default=dataclasses.MISSING, default_factory=dataclasses.MISSING, init=True, repr=True, hash=None, compare=True, metadata=None, kw_only=dataclasses.MISSING):
            if (
                default is not dataclasses.MISSING
                and default_factory is not dataclasses.MISSING
            ):
                raise ValueError("cannot specify both default and default_factory")
            return dataclasses.Field( default, default_factory, init, repr, hash, compare, metadata)

        # fmt: on

        setattr(
            dataclasses,
            "field",
            field,
        )


def patch_inspect(**args):
    import inspect

    if sys.version_info < (3, 10):
        import functools
        import types

        # fmt: off

        def get_annotations(obj, *, globals=None, locals=None, eval_str=False):
            """Compute the annotations dict for an object.

            obj may be a callable, class, or module.
            Passing in an object of any other type raises TypeError.

            Returns a dict.  get_annotations() returns a new dict every time
            it's called; calling it twice on the same object will return two
            different but equivalent dicts.

            This function handles several details for you:

            * If eval_str is true, values of type str will
                be un-stringized using eval().  This is intended
                for use with stringized annotations
                ("from __future__ import annotations").
            * If obj doesn't have an annotations dict, returns an
                empty dict.  (Functions and methods always have an
                annotations dict; classes, modules, and other types of
                callables may not.)
            * Ignores inherited annotations on classes.  If a class
                doesn't have its own annotations dict, returns an empty dict.
            * All accesses to object members and dict values are done
                using getattr() and dict.get() for safety.
            * Always, always, always returns a freshly-created dict.

            eval_str controls whether or not values of type str are replaced
            with the result of calling eval() on those values:

            * If eval_str is true, eval() is called on values of type str.
            * If eval_str is false (the default), values of type str are unchanged.

            globals and locals are passed in to eval(); see the documentation
            for eval() for more information.  If either globals or locals is
            None, this function may replace that value with a context-specific
            default, contingent on type(obj):

            * If obj is a module, globals defaults to obj.__dict__.
            * If obj is a class, globals defaults to
                sys.modules[obj.__module__].__dict__ and locals
                defaults to the obj class namespace.
            * If obj is a callable, globals defaults to obj.__globals__,
                although if obj is a wrapped function (using
                functools.update_wrapper()) it is first unwrapped.
            """
            if isinstance(obj, type):
                # class
                obj_dict = getattr(obj, '__dict__', None)
                if obj_dict and hasattr(obj_dict, 'get'):
                    ann = obj_dict.get('__annotations__', None)
                    if isinstance(ann, types.GetSetDescriptorType):
                        ann = None
                else:
                    ann = None

                obj_globals = None
                module_name = getattr(obj, '__module__', None)
                if module_name:
                    module = sys.modules.get(module_name, None)
                    if module:
                        obj_globals = getattr(module, '__dict__', None)
                obj_locals = dict(vars(obj))
                unwrap = obj
            elif isinstance(obj, types.ModuleType):
                # module
                ann = getattr(obj, '__annotations__', None)
                obj_globals = getattr(obj, '__dict__')
                obj_locals = None
                unwrap = None
            elif callable(obj):
                # this includes types.Function, types.BuiltinFunctionType,
                # types.BuiltinMethodType, functools.partial, functools.singledispatch,
                # "class funclike" from Lib/test/test_inspect... on and on it goes.
                ann = getattr(obj, '__annotations__', None)
                obj_globals = getattr(obj, '__globals__', None)
                obj_locals = None
                unwrap = obj
            else:
                raise TypeError(f"{obj!r} is not a module, class, or callable.")

            if ann is None:
                return {}

            if not isinstance(ann, dict):
                raise ValueError(f"{obj!r}.__annotations__ is neither a dict nor None")

            if not ann:
                return {}

            if not eval_str:
                return dict(ann)

            if unwrap is not None:
                while True:
                    if hasattr(unwrap, '__wrapped__'):
                        unwrap = unwrap.__wrapped__
                        continue
                    if isinstance(unwrap, functools.partial):
                        unwrap = unwrap.func
                        continue
                    break
                if hasattr(unwrap, "__globals__"):
                    obj_globals = unwrap.__globals__

            if globals is None:
                globals = obj_globals
            if locals is None:
                locals = obj_locals

            return_value = {key:
                value if not isinstance(value, str) else eval(value, globals, locals)
                for key, value in ann.items() }
            return return_value

        # fmt: on

        setattr(
            inspect,
            "get_annotations",
            get_annotations,
        )


def patch_types(**args):
    import types

    if sys.version_info < (3, 10):
        setattr(
            types,
            "NoneType",
            type(None),
        )
        setattr(
            types,
            "NotImplementedType",
            type(NotImplemented),
        )
        setattr(
            types,
            "EllipsisType",
            type(...),
        )


def patch_typing(**args):
    import typing

    if sys.version_info < (3, 10):
        import typing_extensions

        setattr(
            typing,
            "TypeAlias",
            typing_extensions.TypeAlias,
        )
        setattr(
            typing,
            "Concatenate",
            typing_extensions.Concatenate,
        )
        setattr(
            typing,
            "TypeGuard",
            typing_extensions.TypeGuard,
        )
        setattr(
            typing,
            "ParamSpecArgs",
            typing_extensions.ParamSpecArgs,
        )
        setattr(
            typing,
            "ParamSpecKwargs",
            typing_extensions.ParamSpecKwargs,
        )
        setattr(
            typing,
            "is_typeddict",
            typing_extensions.is_typeddict,
        )

    if sys.version_info < (3, 11):
        import typing_extensions

        setattr(
            typing,
            "LiteralString",
            typing_extensions.LiteralString,
        )
        setattr(
            typing,
            "Never",
            typing_extensions.Never,
        )
        setattr(
            typing,
            "Self",
            typing_extensions.Self,
        )
        setattr(
            typing,
            "Required",
            typing_extensions.Required,
        )
        setattr(
            typing,
            "NotRequired",
            typing_extensions.NotRequired,
        )
        setattr(
            typing,
            "Unpack",
            typing_extensions.Unpack,
        )
        setattr(
            typing,
            "TypeVarTuple",
            typing_extensions.TypeVarTuple,
        )
        setattr(
            typing,
            "assert_type",
            typing_extensions.assert_type,
        )
        setattr(
            typing,
            "assert_never",
            typing_extensions.assert_never,
        )
        setattr(
            typing,
            "reveal_type",
            typing_extensions.reveal_type,
        )
        setattr(
            typing,
            "dataclass_transform",
            typing_extensions.dataclass_transform,
        )
        setattr(
            typing,
            "get_overloads",
            typing_extensions.get_overloads,
        )
        setattr(
            typing,
            "clear_overloads",
            typing_extensions.clear_overloads,
        )


# ################################ INTERFACE ###################################


MONKEYPATCHES = tuple(
    name.removeprefix("patch_")
    for name in globals()
    if name.startswith("patch_")
    # <format-break>
)


def monkeypatch(*patches, **args):
    for name in patches:
        MONKEYPATCHES[name](**args)
