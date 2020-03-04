<template>
  <div id="app">
    <b-navbar toggleable="lg" type="light" variant="success">
      <b-navbar-brand>
        <router-link to="/">
          <img src="./assets/basic.svg" height="40px" alt="Basic">
        </router-link>
      </b-navbar-brand>

      <b-navbar-toggle target="nav-collapse"></b-navbar-toggle>
      <b-collapse id="nav-collapse" is-nav>
        <b-navbar-nav>
          <b-nav-item to="/nurseries">Nurseries</b-nav-item>
          <b-nav-item to="/farms">Farms</b-nav-item>
          <b-nav-item to="/packhouses">Packhouses</b-nav-item>
          <b-nav-item to="/plants">Plants</b-nav-item>
        </b-navbar-nav>

        <b-navbar-nav class="ml-auto">
          <b-nav-item to="/about">About</b-nav-item>
        </b-navbar-nav>
      </b-collapse>
    </b-navbar>
    <router-view :key="$route.path"/>
  </div>
</template>

<script>

export default {
  name: 'app',
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  min-height: 100vh;
}

#nav {
  padding: 30px;
}
</style>
