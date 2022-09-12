# https://github.com/influenceth/cairo-math-64x61

"""StarkNet/Cairo development toolbelt."""

try:
    from importlib import metadata as importlib_metadata
except ImportError:
    import importlib_metadata

try:
    __version__ = importlib_metadata.version("cairo-math-64x61")
except importlib_metadata.PackageNotFoundError:
    __version__ = None
