import jinja2
import os
from sys import argv
from jinja2 import Template
import yaml
import io

class Loader(yaml.Loader):

    def __init__(self, stream):

        self._root = os.path.split(stream.name)[0]

        super(Loader, self).__init__(stream)

    def include(self, node):

        filename = os.path.join(self._root, self.construct_scalar(node))

        with io.open(filename, 'r', encoding='utf8') as f:
            return yaml.load(f, Loader)

Loader.add_constructor('!include', Loader.include)

latex_jinja_env = jinja2.Environment(
    block_start_string = '\BLOCK{',
    block_end_string = '}',
    variable_start_string = '\VAR{',
    variable_end_string = '}',
    comment_start_string = '\#{',
    comment_end_string = '}',
    line_statement_prefix = '%%',
    line_comment_prefix = '%#',
    trim_blocks = True,
    autoescape = False,
    loader = jinja2.FileSystemLoader(os.path.abspath('.'))
)

template = latex_jinja_env.get_template('latex/template.tex')

build_d = "{}{}.build".format(os.path.abspath('.'), os.sep)
generated = "{}{}generated".format(os.path.abspath('.'), os.sep)

def create_folders():
    global build_d
    if not os.path.exists(build_d):  # create the build directory if not existing
        os.makedirs(build_d)
    if not os.path.exists(generated):  # create the build directory if not existing
        os.makedirs(generated)


def main(datafile):
    global template
    create_folders()
    with open(datafile) as inputfile:
        out_name = os.path.splitext(os.path.basename(datafile))[0] + ".tex"
        data = yaml.load(inputfile, Loader)
        output_name = os.path.join(generated, out_name)
        with io.open(output_name, 'w', encoding="utf8") as outfile:
            outfile.write(template.render(data))

#shutil.copy2(out_file+".pdf", os.path.dirname(os.path.realpath(in_file)))


#with open(out_file+".tex", "w") as f:  # saves tex_code to output file
#    f.write(tex_code)

if __name__ == "__main__":
    main(datafile=argv[1])
