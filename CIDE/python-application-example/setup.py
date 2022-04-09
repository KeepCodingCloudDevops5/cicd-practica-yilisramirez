import setuptools

with open("README.md", "r", encoding="utf-8") as readme:
    long_description = readme.read()

setuptools.setup(
    name="keepcodingtest_yilis",
    version="0.0.1",
    author="keepcoder",
    author_email="kcpypitest@gmail.com",
    description="setup ejemplo",
    package_dir={"": "src"},
    packages=setuptools.find_packages(where="src"),
    long_description=long_description,
    long_description_content_type="text/markdown",
    python_requires=">=3.6",
    install_requires=[
       'build',
       'twine'
   ],
)