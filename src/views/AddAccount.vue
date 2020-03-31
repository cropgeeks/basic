<template>
  <b-container class="container-top">
    <h1>Add Account</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Nursery Owners" :items="nurseryOwners"></b-table>
          <p v-if="nurseryOwners.length === 0">No nursery owners found</p>
        </div>
        <div class="row mt-3">
          <b-table striped hover small bordered caption-top caption="Farm Owners" :items="farmOwners"></b-table>
          <p v-if="farmOwners.length === 0">No farm owners found</p>
        </div>

        <b-button v-b-modal.addModal class="float-left" variant="primary">Add account</b-button>
        <b-modal id="addModal" title="Add account" @ok="addAccount">
          <b-form class="mt-3">
            <b-form-group label="Role" label-for="role" label-align="left">
              <b-form-select id="role" size="sm" :options="roles" v-model="selectedRole"></b-form-select>
            </b-form-group>
            <b-form-group label="Name" label-for="name" label-align="left">
              <b-input id="name" type="text" size="sm" v-model="name"/>
            </b-form-group>
            <b-form-group label="Account" label-for="account" label-align="left">
              <b-input id="account" type="text" size="sm" placeholder="0x000..." v-model="account"/>
            </b-form-group>
          </b-form>
        </b-modal>
      </div>
    </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'

export default {
  name: 'home',
  data() {
    return {
      account: null,
      selectedRole: null,
      name: null,
      roles: ["Nursery", "Farmer"],
      nurseryOwners: [],
      farmOwners: []
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      // Specific setup of elements for this page
      this.nurseryManager.deployed().then((contract) => {
        this.initNurseryOwners(contract);
        this.setupNurseryOwnerEvent(contract);
      });

      this.farmManager.deployed().then((contract) => {
        this.initFarmOwners(contract);
        this.setupFarmOwnerEvent(contract);
      });
    })
  },
  methods: {
    // Called from the modal launched via the add account button
    addAccount() {
      // Try to add an account of the selected type
      if (this.selectedRole === "Nursery") {
        this.nurseryManager.deployed().then((contract) => {
          contract.addNurseryOwner(this.name, this.account);
        }).catch(error => {
          // TODO: Flag to the user in some useful way
          console.log(error);
        }).then(() => {
          // We want to blank out our form fields whether we succeeded or failed
          // hence the placement in a then after the catch
          this.account = null;
          this.selectedRole = null;
          this.name = null;
        });
      }

      if (this.selectedRole === "Farmer") {
        this.farmManager.deployed().then((contract) => {
          contract.addFarmOwner(this.name, this.account);
        }).catch(error => {
          // TODO: Flag to the user in some useful way
          console.log(error);
        }).then(() => {
          // We want to blank out our form fields whether we succeeded or failed
          // hence the placement in a then after the catch
          this.account = null;
          this.selectedRole = null;
          this.name = null;
        });
      }
    },
     // Load any existing nursery owners into an array with backs a table
    initNurseryOwners: function(contract) {
      this.nurseryOwners = this.getNurseryOwners(contract);
    },
    // Setup the event listener which checks for the addition of new nursery owners
    setupNurseryOwnerEvent: function(contract) {
      contract.AddedNurseryOwner().on('data', event => {
        let n = {
          name: event.returnValues.name,
          address: event.returnValues.nurseryOwner
        }

        this.nurseryOwners.push(n);
      });
    },
    // Load any existing farm owners into an array with backs a table
    initFarmOwners: function(contract) {
      this.farmOwners = this.getFarmOwners(contract);
    },
    // Setup the event listener which checks for the addition of new farm owners
    setupFarmOwnerEvent: function(contract) {
      contract.AddedFarmOwner().on('data', event => {
        let f = {
          name: event.returnValues.name,
          address: event.returnValues.farmOwner
        }

        this.farmOwners.push(f);
      })
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
</style>
