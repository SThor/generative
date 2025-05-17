import os
import shutil
import subprocess
import sys

def create_new_project(project_name):
    """
    Creates a new Processing project from a template in the 'generative' directory.
    This function performs the following steps:
    1. Verifies execution from the 'generative' directory
    2. Creates and checks out a new Git branch named 'dev/{project_name}'
    3. Copies the template project to a new directory named after the project
    4. Renames the .pde file to match the project name
    Args:
        project_name (str): The name of the new project to create. This will be used
                           for the directory name, the .pde file name, and as part
                           of the Git branch name.
    Raises:
        SystemExit: If the current directory is not 'generative', if there are Git
                   branch issues, if the project folder already exists, or if there
                   are problems copying the template or renaming the .pde file.
    Note:
        This script requires the existence of a 'template' directory within the
        'generative' directory that contains a 'template.pde' file.
    """
    # Ensure the current directory is named "generative"
    current_dir = os.path.realpath(os.getcwd())
    if os.path.basename(current_dir) != "generative":
        print("Error: This script must be run from the 'generative' directory.")
        sys.exit(1)

    # Define paths
    template_dir = os.path.join(current_dir, "template")
    new_project_dir = os.path.join(current_dir, project_name)

    # Step 1: Create and checkout a new Git branch
    branch_name = f"dev/{project_name}"
    try:
        subprocess.run(["git", "checkout", "-b", branch_name], cwd=current_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error creating or checking out branch: {e}")
        sys.exit(1)

    # Step 2: Copy the template project to the new folder
    if not os.path.exists(template_dir):
        print(f"Error: The template directory '{template_dir}' does not exist.")
        sys.exit(1)
    try:
        shutil.copytree(template_dir, new_project_dir)
    except FileExistsError:
        print(f"Error: The project folder '{new_project_dir}' already exists.")
        sys.exit(1)
    except Exception as e:
        print(f"Error copying template: {e}")
        sys.exit(1)

    # Step 3: Rename the .pde file
    template_pde = os.path.join(new_project_dir, "template.pde")
    if not os.path.exists(template_pde):
        print(f"Error: The file '{template_pde}' does not exist.")
        sys.exit(1)
    try:
        new_pde = os.path.join(new_project_dir, f"{project_name}.pde")
        os.rename(template_pde, new_pde)
    except Exception as e:
        print(f"Error renaming .pde file: {e}")
        sys.exit(1)

    print(f"New project '{project_name}' created successfully on branch '{branch_name}' at '{new_project_dir}'.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        project_name = sys.argv[1]
    else:
        project_name = input("Enter the new project name: ").strip()

    if not project_name:
        print("Error: Project name cannot be empty or consist only of whitespace.")
        sys.exit(1)

    create_new_project(project_name)