<template>
  <b-container class="container-top">
    <b-breadcrumb :items="breadcrumbs"></b-breadcrumb>
    <h1>Farm</h1>
    <div class="row" v-if="farm !== null">
      <div class="col">
        <div class="row">
          <h2>{{ farm.name }}</h2>
        </div>
        <div class="row">
          <p>{{ farm.description }}</p>
        </div>

        <div class="row">
          <b-button v-if="isFarmOwner" v-b-modal.addEmployeeModal class="float-left" variant="primary">Add employee</b-button>
        </div>

        <div class="row">
          <b-table class="mb-0" striped hover small bordered caption-top caption="Employees" :items="employees" :per-page="perPage" :current-page="currentPage"></b-table>
          <b-pagination
            v-if="employees.length > 0"
            v-model="currentPage"
            :total-rows="employees.length"
            :per-page="perPage"
            size="sm"
          ></b-pagination>
        </div>

        <b-modal id="addEmployeeModal" title="Add Employee" @ok="addEmployee">
          <b-form>
            <b-form-group label="Name" label-for="name" label-align="left">
              <b-input id="name" size="sm" v-model="employeeName"></b-input>
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
      farm: null,
      isFarmOwner: false,
      perPage: 10,
      currentPage: 1,
      employees: [],
      employeeName: null,
      breadcrumbs: [
        {
          text: "Home",
          to: { name: 'home' }
        },
        {
          text: "Farms",
          to: { name: 'farms'}
        },
        {
          text: "Farm",
          to: { name: 'farm', params: { farmId: this.$route.params.farmId }}
        },
        {
          text: "Employees",
          active: true
        }
      ]
    }
  },
  mounted() {
    web3.eth.getAccounts().then(() => {
      this.farmManager.deployed().then((contract) => {
        this.initFarm(contract);
        this.initFarmEmployees(contract);
        this.setupEmployeeAddedEvent(contract);

        contract.isFarmOwner(this.$route.params.farmId).then(isFarmer => {
          this.isFarmOwner = isFarmer;
        })
      })
    })
  },
  methods: {
    initFarm: function(contract) {
      // Retrieve farm info
      contract.getFarm(this.$route.params.farmId).then((f) => {
        this.farm = {
          id: f[0].toNumber(),
          name: f[1].toString(),
          lat: f[2].toNumber(),
          long: f[3].toNumber(),
          description: f[4].toString(),
          ownerName: f[5].toString(),
          ownerAddress: f[6].toString()
        }
      })
    },
    initFarmEmployees: function(contract) {
      contract.getEmployeeCount().then((count) => {
        for (let i=0; i < count; i++) {
          contract.getEmployee(i).then((e) => {
            let employee = {
              id: e[0].toNumber(),
              name: e[2].toString()
            }
            this.employees.push(employee);
          })
        }
      })
    },
    addEmployee: function() {
      this.farmManager.deployed().then((contract) => {
        contract.addEmployee(this.farm.id, this.employeeName);
      }).catch(error => {
        console.log(error);
      }).then(() => {
        this.employeeName = null;
      })
    },
    setupEmployeeAddedEvent: function(contract) {
      contract.AddedEmployee().on('data', event => {
        if (event.returnValues.farmId === this.$route.params.farmId) {
          let e = {
            id: event.returnValues.employeeId,
            name: event.returnValues.name
          }
          this.employees.push(e);
        }
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
