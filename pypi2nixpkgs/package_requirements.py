from pathlib import Path
from typing import Sequence
from dataclasses import dataclass
from packaging.requirements import Requirement
from pkg_resources import parse_requirements
from pypi2nixpkgs.nixpkgs_sources import run_nix_build


@dataclass
class PackageRequirements:
    build_requirements: Sequence[Requirement]
    test_requirements: Sequence[Requirement]
    runtime_requirements: Sequence[Requirement]

    def __init__(self, result_path: Path):
        attr_mapping = {
            'build_requirements': Path('setup_requires.txt'),
            'test_requirements': Path('tests_requires.txt'),
            'runtime_requirements': Path('install_requires.txt'),
        }
        for (attr, filename) in attr_mapping.items():
            with (result_path / filename).open() as fp:
                # Convert from Requirement.parse to Requirement
                reqs = [Requirement(str(r)) for r in parse_requirements(fp)]
                setattr(self, attr, reqs)


async def eval_package_requirements(package: Path) -> PackageRequirements:
    nix_expression_path = Path('__file__').parent.parent / "parse_setuppy_data.nix"
    assert nix_expression_path.exists()
    nix_store_path = await run_nix_build(
        str(nix_expression_path),
        '--no-out-link',
        '--arg',
        'file',
        str(package.absolute())
    )
    return PackageRequirements(nix_store_path)
