<template>
  <b-container class="container-top">
    <h1>Nurseries</h1>
    <div class="row" v-if="isAdmin">
      <div class="col">
        <h2>Add Nursery</h2>
        <b-form>
          <b-form-group label="Name" label-for="nursery-name" label-align="left">
            <b-input id="nursery-name" size="sm" placeholder="Name" v-model="nurseryName"/>
          </b-form-group>
          <b-form-group label="Latitude" label-for="nursery-lat" label-align="left">
            <b-input id="nursery-lat" size="sm" placeholder="0" type="number" step="0.01" min="-90" max="90" v-model="nurseryLat"/>
          </b-form-group>
          <b-form-group label="Longitude" label-for="nursery-long" label-align="left">
            <b-input id="nursery-long" size="sm" placeholder="0" type="number" step="0.01" min="-180" max="180" v-model="nurseryLong"/>
          </b-form-group>
          <b-form-group label="Description" label-for="nursery-desc" label-align="left">
            <b-input id="nursery-description" type="text" size="sm" placeholder="Nursery description" v-model="nurseryDesc"/>
          </b-form-group>
          <button class="btn btn-primary float-left" type="submit">Add nursery</button>
        </b-form>
      </div>
    </div>
    <div class="row mt-3">
      <div v-for="nursery in nurseries" v-bind:key="nursery.id" class="col-md-3 col-6 my-1">
        <div class="card h-100">
        <div class="card-body">
          <div class="card-title">{{ nursery.name }}</div>
          <div class="card-text">
            {{ nursery.description }}
          </div>
        </div>
        <div class="card-footer">
          <b-button @click="$router.push({ name: 'nursery', params: { nurseryId: nursery.id }})" variant="primary">View</b-button>
        </div>
      </div>
    </div>
  </div>
  </b-container>

</template>

<script>
import web3 from '../util/getWeb3'
import Supply from '../../build/contracts/Supply.json'
import TruffleContract from 'truffle-contract'

export default {
  name: 'home',
  data() {
    return {
      w3: web3,
      defaultAccount: null,
      supplyContract: null,
      nurseries: [],
      nurseryName: null,
      nurseryLat: null,
      nurseryLong: null,
      nurseryDesc: null
    }
  },
  mounted() {
    web3.eth.getAccounts().then((acc) => {
      this.defaultAccount = acc[0]
      web3.eth.defaultAccount = acc[0]

      this.supplyContract = TruffleContract(Supply)
      
      this.supplyContract.setProvider(this.w3.currentProvider)
      this.supplyContract.defaults({from: this.w3.eth.defaultAccount})

      this.supplyContract.deployed().then((contract) => {
        this.nurseries = this.getNurseries(contract);
        // contract.getNurseryCount().then((count) => {
        //   for (var i = 0; i < count; i++) {
        //     contract.getNursery(i).then((nursery) => {
        //       this.addNursery(nursery);
        //     })
        //   }
        // })
      })
    })
  },
  methods: {
    addNursery: function(nursery) {
      let n = {
        id: nursery[0].toNumber(),
        name: nursery[1].toString(),
        lat: nursery[2].toNumber(),
        long: nursery[3].toNumber(),
        description: nursery[4].toString(),
      }

      this.nurseries.push(n);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.container-top{
  margin-top: 2%;
}
.card-header{
  background-color: rgba(0, 0, 0, 0.000000001);
  border-bottom: 0px;
}
</style>
