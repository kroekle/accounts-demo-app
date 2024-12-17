function StateServices() {

    this.getAttribute = async (attribute) => {
        const response = await fetch(`/attributes/${attribute}`, {
            method: "GET",
        });

        if (response.ok) {
            var resp = await response.json();
            return resp.value;
        } else {
            throw new Error(`Request failed with status ${response.status}`);
        }
    }

    this.setAttribute = async (attribute, value) => {
        const method = value ? "POST" : "DELETE";
        const response = await fetch(`/attributes/${attribute}`, {
            method: method,
        });

        if (response.ok) {
            return value;
        } else {
            throw new Error(`Request failed with status ${response.status}`);
        }
    }

}

export default StateServices;