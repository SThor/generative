import os
import shutil
import subprocess
import sys

def create_new_project(project_name):
    # Ensure the current directory is named "generative"
    current_dir = os.getcwd()
    if not current_dir.endswith("generative"):
        print("Error: This script must be run from the 'generative' directory.")
        sys.exit(1)

    # Define paths
    template_dir = os.path.join(current_dir, "template")
    template_pde = os.path.join(template_dir, "template.pde")
    new_project_dir = os.path.join(current_dir, project_name)

    # Step 1: Create and checkout a new Git branch
    branch_name = f"dev/{project_name}"
    try:
        subprocess.run(["git", "checkout", "-b", branch_name], cwd=current_dir, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error creating or checking out branch: {e}")
        sys.exit(1)

    # Step 2: Copy the template project to the new folder
    try:
        shutil.copytree(template_dir, new_project_dir)
    except FileExistsError:
        print(f"Error: The project folder '{new_project_dir}' already exists.")
        sys.exit(1)
    except Exception as e:
        print(f"Error copying template: {e}")
        sys.exit(1)

    # Step 3: Rename the .pde file
    try:
        new_pde = os.path.join(new_project_dir, f"{project_name}.pde")
        os.rename(os.path.join(new_project_dir, "template.pde"), new_pde)
    except Exception as e:
        print(f"Error renaming .pde file: {e}")
        sys.exit(1)

    print(f"New project '{project_name}' created successfully.")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        project_name = sys.argv[1]
    else:
        project_name = input("Enter the new project name: ").strip()

    if not project_name:
        print("Error: Project name cannot be empty.")
        sys.exit(1)

    create_new_project(project_name)