import subprocess
import time
from flask import Flask

app = Flask(__name__)

def run_command_with_retry(command, max_retries=10, retry_delay=1):
    """
    Executes a command with retries in case of errors.

    Args:
        command (list): The command to execute as a list of arguments.
        max_retries (int): The maximum number of retry attempts.
        retry_delay (int): The delay between attempts in seconds.

    Returns:
        subprocess.CompletedProcess: A CompletedProcess object with the result of the last attempt.
    """
    for i in range(max_retries):
        result = subprocess.run(command, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"Command '{command}' executed successfully: {result.stdout}")
            return result
        else:
            print(f"Error executing command: {command}\n{result.stdout}\n{result.stderr}")
            if i < max_retries - 1:
                print(f"Retrying in {retry_delay} seconds...")
                time.sleep(retry_delay)
    return result

@app.route('/update', methods=['GET', 'POST'])
def update():
    """
    Endpoint /update that performs git_pillar and fileserver updates.
    """
    commands = [
        ["/usr/bin/sudo", "/usr/bin/salt-run", "git_pillar.update"],
        ["/usr/bin/sudo", "/usr/bin/salt-run", "fileserver.update"]
    ]
    results = {}
    for command in commands:
        command_name = command[1]  # Command name (e.g., git_pillar.update)
        result = run_command_with_retry(command)
        if result.returncode == 0:
            results[command_name] = f"Command '{' '.join(command)}' executed successfully:\n{result.stdout}"
        else:
            output_message = result.stdout if result.stdout else ""
            error_message = result.stderr if result.stderr else "No error message received."
            combined_message = f"{output_message}\n{error_message}" if output_message else error_message
            results[command_name] = (
                f"Error executing command '{' '.join(command)}' after {run_command_with_retry.__defaults__[0]} attempts:\n"
                f"{combined_message}"
            )

    
    # Return results as text
    response_text = "\n".join(results.values())
    return response_text, 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
